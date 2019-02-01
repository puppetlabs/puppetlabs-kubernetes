require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'rspec/retry'

begin
  require 'pry'
rescue LoadError # rubocop:disable Lint/HandleExceptions for optional loading
end

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # show retry status in spec process
  c.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  c.display_try_failure_messages = true

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      # Return the hostname on :dashboard
      vmhostname = on(host, 'hostname', acceptable_exit_codes: [0]).stdout.strip
      vmipaddr = on(host, "ip route get 8.8.8.8 | awk '{print $NF; exit}'", acceptable_exit_codes: [0]).stdout.strip
      os = fact_on(host, 'osfamily')

      copy_module_to(host, :source => proj_root, :module_name => 'kubernetes')
      if fact_on(host, 'operatingsystem') == 'RedHat'
        on(host, 'mv /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/internal-mirror.repo')
      end

      on(host, 'yum update -y -q') if fact_on(host, 'osfamily') == 'RedHat'

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'stahnma-epel'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-translate', '--version', '1.0.0' ), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppet-archive'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'herculesteam-augeasproviders_sysctl'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'herculesteam-augeasproviders_core'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'camptocamp-kmod'), { :acceptable_exit_codes => [0,1] }


      # shell('echo "#{vmhostname}" > /etc/hostname')
      # shell("hostname #{vmhostname}")
      hosts_file = <<-EOS
127.0.0.1 localhost #{vmhostname} kubernetes kube-master
#{vmipaddr} #{vmhostname}
#{vmipaddr} kubernetes
#{vmipaddr} kube-master
      EOS

      nginx = <<-EOS
apiVersion: v1
kind: Namespace
metadata:
  name: nginx
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: my-nginx
  namespace: nginx
spec:
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx:1.12-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  namespace: nginx
  labels:
    run: my-nginx
spec:
  clusterIP: 10.96.188.5
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
EOS

      hiera = <<-EOS
:backends:
  - yaml
:hierarchy:
  - "%{::hostname}"
  - "%{::osfamily}"
:yaml:
  :datadir: /etc/puppetlabs/code/environments/production/hieradata
EOS


        if fact('osfamily') == 'Debian'
          runtime = 'cri_containerd'
          cni = 'weave'
          #Installing rubydev environment
          on(host, "apt install ruby-bundler --yes", acceptable_exit_codes: [0]).stdout
          on(host, "apt-get install ruby-dev --yes", acceptable_exit_codes: [0]).stdout
          on(host, "apt-get install build-essential curl git m4 python-setuptools ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev --yes", acceptable_exit_codes: [0]).stdout
        end
        if fact('osfamily') == 'RedHat'
          runtime = 'cri_containerd'
          cni = 'flannel'
          #Installing rubydev environment
          on(host, "yum install -y ruby-devel git zlib-devel gcc-c++ lib yaml-devel libffi-devel make bzip2 libtool curl openssl-devel readline-devel", acceptable_exit_codes: [0]).stdout
          on(host, "gem install bundler", acceptable_exit_codes: [0]).stdout
          on(host, "git clone git://github.com/sstephenson/rbenv.git .rbenv", acceptable_exit_codes: [0]).stdout
          on(host, "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bash_profile", acceptable_exit_codes: [0]).stdout
          on(host, "echo 'eval \"$(rbenv init -)\"' >> ~/.bash_profile" ,acceptable_exit_codes: [0]).stdout
          on(host, "git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build", acceptable_exit_codes: [0]).stdout
          on(host, "echo 'export PATH=\"$HOME/.rbenv/plugins/ruby-build/bin:$PATH\"' >> ~/.bash_profile", acceptable_exit_codes: [0]).stdout
          on(host, "source ~/.bash_profile;rbenv install -v 2.3.1;rbenv global 2.3.1;rbenv local 2.3.1", acceptable_exit_codes: [0]).stdout
        end

        # Installing go, cfssl
        on(host, "cd  /etc/puppetlabs/code/modules/kubernetes;rm -rf Gemfile.lock;bundle install --path vendor/bundle", acceptable_exit_codes: [0]).stdout
        on(host, "curl -o go.tar.gz https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz", acceptable_exit_codes: [0]).stdout
        on(host, "tar -C /usr/local -xzf go.tar.gz", acceptable_exit_codes: [0]).stdout
        on(host, "export PATH=$PATH:/usr/local/go/bin;go get -u github.com/cloudflare/cfssl/cmd/...", acceptable_exit_codes: [0]).stdout
        # Creating certs
        on(host, "source ~/.bash_profile;rbenv global 2.3.1;rbenv local 2.3.1;export PATH=$PATH:/usr/local/go/bin;export PATH=$PATH:/root/go/bin;cd  /etc/puppetlabs/code/modules/kubernetes/tooling;./kube_tool.rb -o #{os} -v 1.10.2 -r #{runtime} -c #{cni} -i \"#{vmhostname}:#{vmipaddr}\" -t \"#{vmipaddr}\" -a \"#{vmipaddr}\" -d true", acceptable_exit_codes: [0]).stdout
        create_remote_file(host, "/etc/hosts", hosts_file)
        create_remote_file(host, "/tmp/nginx.yml", nginx)
        create_remote_file(host,"/etc/puppetlabs/puppet/hiera.yaml", hiera)
        on(host, 'cp /etc/puppetlabs/code/modules/kubernetes/tooling/*.yaml /etc/puppetlabs/code/environments/production/hieradata/', acceptable_exit_codes: [0]).stdout


        if fact('osfamily') == 'Debian'
          on(host, 'sed -i /cni_network_provider/d /etc/puppetlabs/code/environments/production/hieradata/Debian.yaml', acceptable_exit_codes: [0]).stdout
          on(host, 'echo "kubernetes::cni_network_provider: https://cloud.weave.works/k8s/net?k8s-version=\$(kubectl version | base64 | tr -d \"\n\")\&env.IPALLOC_RANGE=100.32.0.0/12" >> /etc/puppetlabs/code/environments/production/hieradata/Debian.yaml', acceptable_exit_codes: [0]).stdout
        end
    end
  end
end
