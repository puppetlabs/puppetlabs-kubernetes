# frozen_string_literal: true

require 'puppet_litmus'
require 'tempfile'

include PuppetLitmus

def create_remote_file(name, full_name, file_content)
  Tempfile.open name do |tempfile|
    File.open(tempfile.path, 'w') { |file| file.puts file_content }
    bolt_upload_file(tempfile.path, full_name)
  end
end

def inventory_hash
  @inventory_hash ||= inventory_hash_from_inventory_file
end

def target_roles(roles)
  inventory_hash['groups'].map { |group|
    group['targets'].filter_map do |node|
      { name: node['uri'], role: node['vars']['role'] } if roles.include? node['vars']['role']
    end
  }.flatten
end

def fetch_platform_by_node(uri)
  inventory_hash['groups'].map do |group|
    group['targets'].map do |node|
      return node['facts']['platform'] if node['uri'] == uri

      return nil
    end
  end
end

def fetch_ip_hostname_by_role(role)
  # Fetch hostname and  ip adress for each node
  ipaddr = target_roles(role)[0][:name]
  platform = fetch_platform_by_node(ipaddr)
  ENV['TARGET_HOST'] = target_roles(role)[0][:name]
  hostname = run_shell('hostname').stdout.strip
  int_ipaddr = run_shell("ip route get 8.8.8.8 | awk '{print $7; exit}'").stdout.strip
  [hostname, ipaddr, int_ipaddr]
end

def change_target_host(role)
  @orig_target_host = ENV.fetch('TARGET_HOST', nil)
  ENV['TARGET_HOST'] = target_roles(role)[0][:name]
end

def os_family
  run_shell("facter -y os.family | cut -d':' -f2 | tr -d ' '").stdout.strip
end

def reset_target_host
  ENV['TARGET_HOST'] = @orig_target_host
end

def configure_puppet_server(controller, worker1, worker2)
  # Configure the puppet server
  ENV['TARGET_HOST'] = target_roles('controller')[0][:name]
  run_shell('systemctl start puppetserver')
  run_shell('systemctl enable puppetserver')
  # Point local agent to this server
  run_shell('puppet config set server puppet --section main')
  execute_agent('controller')
  # Configure the puppet agents
  configure_puppet_agent('worker1')
  puppet_cert_sign
  configure_puppet_agent('worker2')
  puppet_cert_sign
  # Create site.pp

  site_pp = if os_family.casecmp('redhat').zero?
              <<-EOS
                node /#{controller[0]}/ {
                  class {'kubernetes':
                    kubernetes_version => '1.28.15',
                    kubernetes_package_version => '1.28.15',
                    kubernetes_yum_baseurl => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/',
                    kubernetes_yum_gpgkey => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key',
                    controller_address => "#{controller[1]}:6443",
                    container_runtime => 'docker',
                    manage_docker => false,
                    controller => true,
                    schedule_on_controller => true,
                    environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                    ignore_preflight_errors => ['NumCPU','ExternalEtcdVersion'],
                    cgroup_driver => 'systemd',
                    service_cidr => '10.138.0.0/12',
                  }
                }

                node /#{worker1}/ {
                  class {'kubernetes':
                    kubernetes_version => '1.28.15',
                    kubernetes_package_version => '1.28.15',
                    kubernetes_yum_baseurl => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/',
                    kubernetes_yum_gpgkey => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key',
                    worker => true,
                    manage_docker => false,
                    cgroup_driver => 'systemd',
                  }
                }

                node /#{worker2}/  {
                  class {'kubernetes':
                    kubernetes_version => '1.28.15',
                    kubernetes_package_version => '1.28.15',
                    kubernetes_yum_baseurl => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/',
                    kubernetes_yum_gpgkey => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key',
                    worker => true,
                    manage_docker => false,
                    cgroup_driver => 'systemd',
                  }
                }
              EOS
            else
              <<-EOS
                node /#{controller[0]}/ {
                  class {'kubernetes':
                    kubernetes_version => '1.28.15',
                    kubernetes_package_version => '1.28.15-1.1',
                    kubernetes_apt_location => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/',
                    kubernetes_apt_repos => ' ',
                    kubernetes_apt_release => ' /',
                    kubernetes_key_source => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key',
                    controller_address => "#{controller[1]}:6443",
                    container_runtime => 'cri_containerd',
                    manage_docker => false,
                    controller => true,
                    schedule_on_controller => true,
                    environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                    ignore_preflight_errors => ['NumCPU','ExternalEtcdVersion'],
                    cgroup_driver => 'systemd',
                    service_cidr => '10.138.0.0/12',
                  }
                }

                node /#{worker1}/ {
                  class {'kubernetes':
                    kubernetes_version => '1.28.15',
                    kubernetes_package_version => '1.28.15-1.1',
                    kubernetes_apt_location => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/',
                    kubernetes_apt_repos => ' ',
                    kubernetes_apt_release => ' /',
                    kubernetes_key_source => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key',
                    worker => true,
                    manage_docker => false,
                    cgroup_driver => 'systemd',
                  }
                }

                node /#{worker2}/  {
                  class {'kubernetes':
                    kubernetes_version => '1.28.15',
                    kubernetes_package_version => '1.28.15-1.1',
                    kubernetes_apt_location => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/',
                    kubernetes_apt_repos => ' ',
                    kubernetes_apt_release => ' /',
                    kubernetes_key_source => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key',
                    worker => true,
                    manage_docker => false,
                    cgroup_driver => 'systemd',
                  }
                }
              EOS
            end

  ENV['TARGET_HOST'] = target_roles('controller')[0][:name]
  create_remote_file('site', '/etc/puppetlabs/code/environments/production/manifests/site.pp', site_pp)
  run_shell('chmod 644 /etc/puppetlabs/code/environments/production/manifests/site.pp')
end

def configure_puppet_agent(role)
  # Configure the puppet agents
  ENV['TARGET_HOST'] = target_roles(role)[0][:name]
  # Ensure agent knows server hostname
  run_shell('puppet config set server puppet --section main')
  run_shell('systemctl start puppet')
  run_shell('systemctl enable puppet')
  execute_agent(role)
end

def puppet_cert_sign
  # Sign the certs
  ENV['TARGET_HOST'] = target_roles('controller')[0][:name]
  run_shell('puppetserver ca sign --all', expect_failures: true)
end

def clear_certs(role)
  ENV['TARGET_HOST'] = target_roles(role)[0][:name]
  run_shell('rm -rf /etc/kubernetes/kubelet.conf /etc/kubernetes/pki/ca.crt /etc/kubernetes/bootstrap-kubelet.conf')
end

def execute_agent(role)
  ENV['TARGET_HOST'] = target_roles(role)[0][:name]
  run_shell('puppet agent --test', expect_failures: true)
end

def reset_and_restart_containerd
  ['controller', 'worker1', 'worker2'].each do |node|
    ENV['TARGET_HOST'] = target_roles(node)[0][:name]
    if os_family.casecmp('redhat').zero?
      run_shell('rm -f /etc/containerd/config.toml')
      run_shell('systemctl restart containerd')
    else
      run_shell('wget https://github.com/containerd/containerd/releases/download/v1.6.12/containerd-1.6.12-linux-amd64.tar.gz && tar xvf containerd-1.6.12-linux-amd64.tar.gz')
      run_shell('systemctl stop containerd')
      run_shell('cd bin && cp * /usr/bin/')
      run_shell('systemctl start containerd')
    end
  end
end

def open_communication_ports
  ['controller', 'worker1', 'worker2'].each do |node|
    ENV['TARGET_HOST'] = target_roles(node)[0][:name]
    if node == 'controller'
      run_shell('iptables -I INPUT -p tcp -m multiport --dports 2379,2380,6443,10250,10251,10252,30000:32767 -j ACCEPT')
    else
      run_shell('iptables -I INPUT -p tcp -m multiport --dports 10251,10252,10255,30000:32767 -j ACCEPT')
    end
    run_shell('iptables -I INPUT -p udp -m multiport --dports 8472 -j ACCEPT')
    if os_family.casecmp('redhat').zero?
      run_shell('iptables-save > /etc/sysconfig/iptables')
    else
      run_shell('iptables-save > /etc/iptables/rules.v4')
    end
  end
end

RSpec.configure do |c|
  c.before :suite do
    # Fetch hostname and  ip adress for each node
    hostname1, ipaddr1, int_ipaddr1 = fetch_ip_hostname_by_role('controller')
    hostname2, _ipaddr2, int_ipaddr2 =  fetch_ip_hostname_by_role('worker1')
    hostname3, _ipaddr3, int_ipaddr3 =  fetch_ip_hostname_by_role('worker2')

    if c.filter.rules.key? :integration
      ENV['TARGET_HOST'] = target_roles('controller')[0][:name]
      ['controller', 'worker1', 'worker2'].each do |node|
        ENV['TARGET_HOST'] = target_roles(node)[0][:name]
        run_shell("echo #{int_ipaddr1} puppet  >> /etc/hosts")
      end
      configure_puppet_server([hostname1, int_ipaddr1], hostname2, hostname3)
    else
      c.filter_run_excluding :integration
    end
    ENV['TARGET_HOST'] = target_roles('controller')[0][:name]
    family = fetch_platform_by_node(ENV.fetch('TARGET_HOST', nil))

    puts "Running acceptance test on #{hostname1} with address #{ipaddr1} and OS #{family}"

    run_shell('puppet module install puppetlabs-stdlib')
    run_shell('puppet module install puppetlabs-apt')
    run_shell('puppet module install maestrodev-wget')
    run_shell('puppet module install puppet-archive')
    run_shell('puppet module install puppet-augeasproviders_sysctl')
    run_shell('puppet module install puppet-augeasproviders_core')
    run_shell('puppet module install puppet-kmod')
    run_shell('puppet module install puppetlabs-docker')
    run_shell('puppet module install puppetlabs-helm')
    run_shell('puppet module install puppetlabs-rook --ignore-dependencies')

    nginx = <<~EOS
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: my-nginx
      spec:
        selector:
          matchLabels:
            run: my-nginx
        replicas: 2
        template:
          metadata:
            labels:
              run: my-nginx
          spec:
            containers:
            - name: my-nginx
              image: nginx
              ports:
              - containerPort: 80
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: my-nginx
        labels:
          run: my-nginx
      spec:
        ports:
        - port: 80
          protocol: TCP
        selector:
          run: my-nginx
    EOS

    hiera = <<~EOS
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
            - "#{family.capitalize}.yaml"
            - "#{hostname1}.yaml"
            - "Redhat.yaml"
            - "common.yaml"
    EOS

    k8repo = <<~EOS
      [kubernetes]
      name=Kubernetes
      baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
      enabled=1
      gpgcheck=1
      gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
    EOS

    pp = <<-PUPPETCODE
      # needed by tests
      package { 'curl':
        ensure   => 'latest',
      }
      package { 'git':
        ensure   => 'latest',
      }
    PUPPETCODE

    apply_manifest(pp)

    if %r{debian|ubuntu}.match?(family)
      runtime = 'cri_containerd'
      cni = 'weave'
      ['controller', 'worker1', 'worker2'].each do |node|
        ENV['TARGET_HOST'] = target_roles(node)[0][:name]

        run_shell('apt update && apt install apt-transport-https -y')
        run_shell('mkdir -p /etc/apt/keyrings')
        run_shell('apt-get install -y curl gnupg2 software-properties-common')

        if %r{debian-(10|11)}.match?(family)
          run_shell('curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -')
          run_shell('add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"')
        else
          run_shell('curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -')
          run_shell('add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"')
        end
        run_shell('curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg')
        run_shell('echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list')

        run_shell('apt-get update')
        run_shell('apt install containerd -y')
        run_shell('apt install kubectl kubelet kubeadm -y')
        run_shell('apt-mark hold kubectl kubelet kubeadm')
        run_shell('apt install docker-ce docker-ce-cli -y')
        run_shell('apt install docker.io -y')
        run_shell('systemctl start docker.service')
        run_shell('systemctl enable docker.service')
        run_shell('echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections')
        run_shell('echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections')
        run_shell('apt install iptables-persistent -y')
        if family.include?('ubuntu')
          run_shell('sudo ufw disable')
        else
          # Workaround for debian as the strech repositories do not have updated kubernetes packages
          # run_shell('echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kube-xenial.list')
          run_shell('/sbin/iptables -F')
        end
      end
    end

    if %r{rhel|redhat|centos}.match?(family)
      runtime = 'docker'
      cni = 'weave'
      ['controller', 'worker1', 'worker2'].each do |node|
        ENV['TARGET_HOST'] = target_roles(node)[0][:name]
        run_shell('setenforce 0 || true')
        run_shell('swapoff -a')
        run_shell('systemctl stop firewalld && systemctl disable firewalld')
        run_shell('yum install -y yum-utils device-mapper-persistent-data lvm2')
        run_shell('yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo')
        run_shell('yum update -y --nobest')
        run_shell('yum install -y docker-ce-cli')
        run_shell('yum install -y docker-ce')
        run_shell('usermod -aG docker $(whoami)')
        run_shell('systemctl start docker.service')
        run_shell('systemctl enable docker.service')
        create_remote_file('k8repo', '/etc/yum.repos.d/kubernetes.repo', k8repo)
        run_shell('yum install -y kubectl')
      end
    end

    ENV['TARGET_HOST'] = target_roles('controller')[0][:name]

    run_shell('docker build -t kubetool:latest --network host /etc/puppetlabs/code/environments/production/modules/kubernetes/tooling')

    docker_run = <<~DOCKER
      docker run --rm -v $(pwd)/hieradata:/mnt -e OS=#{family} \
                                               -e VERSION=1.28.15 \
                                               -e CONTAINER_RUNTIME=#{runtime} \
                                               -e CNI_PROVIDER=#{cni} \
                                               -e ETCD_INITIAL_CLUSTER=#{hostname1}:#{int_ipaddr1} \
                                               -e ETCD_IP=#{int_ipaddr1} \
                                               -e ETCD_PEERS=[#{int_ipaddr1},#{int_ipaddr2},#{int_ipaddr3}] \
                                               -e KUBE_API_ADVERTISE_ADDRESS=#{int_ipaddr1} \
                                               -e INSTALL_DASHBOARD=true kubetool:latest
    DOCKER

    run_shell(docker_run)

    create_remote_file('nginx', '/tmp/nginx.yml', nginx)
    create_remote_file('hiera', '/etc/puppetlabs/puppet/hiera.yaml', hiera)
    run_shell('chmod 644 /etc/puppetlabs/puppet/hiera.yaml')
    create_remote_file('hiera_prod', '/etc/puppetlabs/code/environments/production/hiera.yaml', hiera)
    run_shell('chmod 644 /etc/puppetlabs/code/environments/production/hiera.yaml')
    run_shell('mkdir -p /etc/puppetlabs/code/environments/production/hieradata')
    run_shell('cp $HOME/hieradata/*.yaml /etc/puppetlabs/code/environments/production/hieradata/')

    run_shell("sed -i /cni_network_provider/d /etc/puppetlabs/code/environments/production/hieradata/#{family.capitalize}.yaml")
    if %r{debian|ubuntu-1604-lts}.match?(family)
      run_shell("echo 'kubernetes::cni_network_provider: https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml' >> /etc/puppetlabs/code/environments/production/hieradata/#{family.capitalize}.yaml") # rubocop:disable Layout/LineLength
    end

    if %r{redhat|centos}.match?(family)
      run_shell("echo 'kubernetes::cni_network_provider: https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml' >> /etc/puppetlabs/code/environments/production/hieradata/#{family.capitalize}.yaml") # rubocop:disable Layout/LineLength
    end

    run_shell("echo 'kubernetes::schedule_on_controller: true'  >> /etc/puppetlabs/code/environments/production/hieradata/#{family.capitalize}.yaml")
    run_shell("echo 'kubernetes::taint_master: false' >> /etc/puppetlabs/code/environments/production/hieradata/#{family.capitalize}.yaml")
    run_shell("echo 'kubernetes::manage_docker: false' >> /etc/puppetlabs/code/environments/production/hieradata/#{family.capitalize}.yaml")

    run_shell("export KUBECONFIG='/etc/kubernetes/admin.conf'")
    reset_and_restart_containerd
    open_communication_ports
    execute_agent('controller')
    execute_agent('worker1')
    execute_agent('worker2')
    puppet_cert_sign
    # Trigger one agent run on controller, then briefly wait for admin.conf
    ENV['TARGET_HOST'] = target_roles('controller')[0][:name]
    run_shell('puppet agent --test || true')
    # Wait for kubeadm to produce admin.conf, then ensure kubeconfig points to a reachable API server
    run_shell('for i in {1..6}; do [ -f /etc/kubernetes/admin.conf ] && echo "admin.conf present" && break; echo "Waiting for /etc/kubernetes/admin.conf... ($i)"; sleep 10; done')
    ensure_kubeconfig_server = <<~SH
      if [ -f /etc/kubernetes/admin.conf ]; then
        IP=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++){if($i=="src"){print $(i+1); exit}}}')
        CTX=$(kubectl --kubeconfig=/etc/kubernetes/admin.conf config current-context || echo kubernetes-admin@kubernetes)
        CLUSTER=$(kubectl --kubeconfig=/etc/kubernetes/admin.conf config view -o jsonpath='{.contexts[?(@.name=="'"$CTX"'")].context.cluster}' || echo kubernetes)
        kubectl --kubeconfig=/etc/kubernetes/admin.conf config set-cluster "$CLUSTER" --server="https://$IP:6443"
      fi
    SH
    run_shell(ensure_kubeconfig_server, expect_failures: true)
    # Apply Weave CNI with validation disabled to avoid openapi call issues
    apply_weave_cni = <<~SH
      if [ -f /etc/kubernetes/admin.conf ]; then
        kubectl --kubeconfig=/etc/kubernetes/admin.conf apply --validate=false \
          -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
      else
        echo "Skipping CNI apply: /etc/kubernetes/admin.conf missing"
        journalctl -u kubelet --no-pager -n 200 || true
      fi
    SH
    run_shell(apply_weave_cni, expect_failures: true)
  end
end
