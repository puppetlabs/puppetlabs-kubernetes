# frozen_string_literal: true
require 'puppet_litmus'
require 'tempfile'

include PuppetLitmus

def create_remote_file(name, full_name, file_content)
  Tempfile.open name do |tempfile|
            File.open(tempfile.path, 'w') {|file| file.puts file_content }
            bolt_upload_file(tempfile.path, full_name)
  end
end

RSpec.configure do |c|
  c.before :suite do
   vmhostname = run_shell('hostname').stdout.strip
   vmipaddr = run_shell("ip route get 8.8.8.8 | awk '{print $NF; exit}'").stdout.strip
   if os[:family] == 'redhat'
     vmipaddr = run_shell("ip route get 8.8.8.8 | awk '{print $7; exit}'").stdout.strip
   end
   vmos = os[:family]

   puts "Running acceptance test on #{vmhostname} with address #{vmipaddr} and OS #{vmos}"

   run_shell('puppet module install puppetlabs-stdlib')
   run_shell('puppet module install puppetlabs-apt')
   run_shell('puppet module install stahnma-epel')
   run_shell('puppet module install maestrodev-wget')
   run_shell('puppet module install puppetlabs-translate')
   run_shell('puppet module install puppet-archive')
   run_shell('puppet module install herculesteam-augeasproviders_sysctl')
   run_shell('puppet module install herculesteam-augeasproviders_core')
   run_shell('puppet module install camptocamp-kmod')
   run_shell('puppet module install puppetlabs-docker')

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
version: 5
defaults:
  datadir: /etc/puppetlabs/code/environments/production/hieradata
  data_hash: yaml_data
hierarchy:
  - name: "Per-node data (yaml version)"
    path: "nodes/%{trusted.certname}.yaml" # Add file extension.
    # Omitting datadir and data_hash to use defaults.
  - name: "Other YAML hierarchy levels"
    paths: # Can specify an array of paths instead of one.
      - "location/%{facts.whereami}/%{facts.group}.yaml"
      - "groups/%{facts.group}.yaml"
      - "os/%{facts.os.family}.yaml"
      - "#{os[:family].capitalize}.yaml"
      - "#{vmhostname}.yaml"
      - "Redhat.yaml"
      - "common.yaml"
EOS

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
    runtime = 'cri_containerd'
    cni = 'weave'
    run_shell('apt-get -y install curl')
    run_shell('DEBIAN_FRONTEND=noninteractive apt-get install ruby-dev --yes')
    run_shell('DEBIAN_FRONTEND=noninteractive apt-get install build-essential curl git m4 python-setuptools ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev --yes')
    run_shell('apt-get -y install ruby-full')
    if os[:family] == 'ubuntu'
      run_shell('sudo ufw disable')
    else
      # Workaround for debian as the strech repositories do not have updated kubernetes packages
      run_shell('echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kube-xenial.list')
      run_shell('/sbin/iptables -F')
    end
  end 
  if os[:family] == 'redhat'
    runtime = 'docker'
    cni = 'flannel'
    run_shell('yum install -y  make bzip2 libtool curl openssl-devel readline-devel ruby-devel git zlib-devel gcc-c++', expect_failures: true)
    run_shell('yum install -y curl gpg gcc gcc-c++ make patch autoconf automake bison libffi-devel libtool patch readline-devel sqlite-devel zlib-devel openssl-devel')
    run_shell('gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB')
    run_shell('setenforce 0 || true')
    run_shell('swapoff -a')
    run_shell('systemctl stop firewalld && systemctl disable firewalld')
    run_shell('yum install -y yum-utils device-mapper-persistent-data lvm2')
    run_shell('yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo')
    run_shell('yum install -y docker-ce-18.06.3.ce-3.el7')
    run_shell("usermod -aG docker $(whoami)")
    run_shell('systemctl start docker.service')
    
  end
  run_shell('curl -o go.tar.gz https://storage.googleapis.com/golang/go1.12.9.linux-amd64.tar.gz')
  run_shell('tar -C /usr/local -xzf go.tar.gz')
  run_shell('export PATH=$PATH:/usr/local/go/bin;go get -u github.com/cloudflare/cfssl/cmd/...')
  run_shell("export PATH=$PATH:/usr/local/go/bin;export PATH=$PATH:/root/go/bin;cd /etc/puppetlabs/code/environments/production/modules/kubernetes/tooling;/opt/puppetlabs/puppet/bin/ruby kube_tool.rb -o #{vmos} -v 1.13.5 -r #{runtime} -c #{cni} -i \"#{vmhostname}:#{vmipaddr}\" -t \"#{vmipaddr}\" -a \"#{vmipaddr}\" -d true")
  create_remote_file("hosts","/etc/hosts", hosts_file)
  create_remote_file("nginx","/tmp/nginx.yml", nginx)
  create_remote_file("hiera","/etc/puppetlabs/puppet/hiera.yaml", hiera)
  create_remote_file("hiera_prod","/etc/puppetlabs/code/environments/production/hiera.yaml", hiera)
  run_shell('mkdir -p /etc/puppetlabs/code/environments/production/hieradata')
  run_shell('cp /etc/puppetlabs/code/environments/production/modules/kubernetes/tooling/*.yaml /etc/puppetlabs/code/environments/production/hieradata/')

  if os[:family] == 'debian'
    run_shell('sed -i /cni_network_provider/d /etc/puppetlabs/code/environments/production/hieradata/Debian.yaml')
    run_shell('echo "kubernetes::cni_network_provider: https://cloud.weave.works/k8s/net?k8s-version=1.13.5" >> /etc/puppetlabs/code/environments/production/hieradata/Debian.yaml')
    run_shell('echo "kubernetes::schedule_on_controller: true"  >> /etc/puppetlabs/code/environments/production/hieradata/Debian.yaml')
    run_shell('echo "kubernetes::taint_master: false" >> /etc/puppetlabs/code/environments/production/hieradata/Debian.yaml')
    run_shell('export KUBECONFIG=\'/etc/kubernetes/admin.conf\'')
  end

  if os[:family] == 'ubuntu'
    run_shell('sed -i /cni_network_provider/d /etc/puppetlabs/code/environments/production/hieradata/Ubuntu.yaml')
    run_shell('echo "kubernetes::cni_network_provider: https://cloud.weave.works/k8s/net?k8s-version=1.13.5" >> /etc/puppetlabs/code/environments/production/hieradata/Ubuntu.yaml')
    run_shell('echo "kubernetes::schedule_on_controller: true"  >> /etc/puppetlabs/code/environments/production/hieradata/Ubuntu.yaml')
    run_shell('echo "kubernetes::taint_master: false" >> /etc/puppetlabs/code/environments/production/hieradata/Ubuntu.yaml')
    run_shell('export KUBECONFIG=\'/etc/kubernetes/admin.conf\'')
  end

  if os[:family] == 'redhat'
    run_shell('sed -i /cni_network_provider/d /etc/puppetlabs/code/environments/production/hieradata/Redhat.yaml')
    run_shell('echo "kubernetes::cni_network_provider: https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml" >> /etc/puppetlabs/code/environments/production/hieradata/Redhat.yaml')
    run_shell('echo "kubernetes::schedule_on_controller: true"  >> /etc/puppetlabs/code/environments/production/hieradata/Redhat.yaml')
    run_shell('echo "kubernetes::taint_master: false" >> /etc/puppetlabs/code/environments/production/hieradata/Redhat.yaml')
    run_shell('export KUBECONFIG=\'/etc/kubernetes/admin.conf\'')
  end

  end
end

