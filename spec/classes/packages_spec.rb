require 'spec_helper'
describe 'kubernetes::packages', :type => :class do
  context 'with osfamily => RedHat and container_runtime => Docker and manage_docker => true and manage_etcd => true' do
    let(:facts) do
      {
        :osfamily         => 'RedHat', #needed to run dependent tests from fixtures camptocamp-kmod
        :kernel           => 'Linux',
        :os               => {
          :family => "RedHat",
          :name    => 'RedHat',
          :release => {
            :full => '7.4',
          },
        },
      }
    end
    let(:pre_condition) {
       '
       exec { \'kubernetes-systemd-reload\': }
       service { \'docker\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
	'docker_storage_driver' => 'overlay2',
	'docker_storage_opts' => ['dm.use_deferred_removal=true','dm.use_deferred_deletion=true'],
        'docker_extra_daemon_config' => '',
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        'etcd_install_method' => 'wget',
        'etcd_package_name' => 'etcd-server',
        'etcd_version' => '3.1.12',
        'create_repos' => true,
        'docker_log_max_file' => '1',
        'docker_log_max_size' => '100m',
        }
    end
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_package('docker-engine').with_ensure('17.03.1.ce-1.el7.centos')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
    it { should contain_file('/etc/docker')}
    it { should contain_file('/etc/docker/daemon.json')}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_removal=true",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_deletion=true"\s*/)}
    it { should contain_file('/etc/systemd/system/docker.service.d')}
  end

  context 'with osfamily => RedHat and container_runtime => Docker and manage_docker => true and manage_etcd => true and etcd_install_method => package' do
    let(:facts) do
      {
        :osfamily         => 'RedHat', #needed to run dependent tests from fixtures camptocamp-kmod
        :kernel           => 'Linux',
        :os               => {
          :family => "RedHat",
          :name    => 'RedHat',
          :release => {
            :full => '7.4',
          },
        },
      }
    end
    let(:pre_condition) {
       '
       exec { \'kubernetes-systemd-reload\': }
       service { \'docker\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
	'docker_storage_driver' => 'overlay2',
	'docker_storage_opts' => ['dm.use_deferred_removal=true','dm.use_deferred_deletion=true'],
        'docker_extra_daemon_config' => 'dummy',
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        'etcd_install_method' => 'package',
        'etcd_package_name' => 'etcd-server',
        'etcd_version' => '3.1.12',
        'create_repos' => true,
        'docker_log_max_file' => '1',
        'docker_log_max_size' => '100m',
        }
    end
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_package('docker-engine').with_ensure('17.03.1.ce-1.el7.centos')}
    it { should_not contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('etcd-server').with_ensure('3.1.12')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
    it { should contain_file('/etc/docker')}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*dummy\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_removal=true",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_deletion=true"\s*/)}
    it { should contain_file('/etc/systemd/system/docker.service.d')}
  end

  context 'with osfamily => Debian and container_runtime => cri_containerd and manage_etcd => false' do
    let(:facts) do
      {
        :osfamily         => 'Debian', #needed to run dependent tests from fixtures camptocamp-kmod
        :kernel           => 'Linux',
        :os               => {
          :family => "Debian",
          :name    => 'Ubuntu',
          :release => {
            :full => '16.04',
          },
          :distro => {
            :codename => "xenial",
          },
        },
      }
    end
    let(:pre_condition) {
       '
       include apt
       exec { \'kubernetes-systemd-reload\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2-00',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
	'docker_storage_driver' => 'overlay2',
	'docker_storage_opts' => ['dm.use_deferred_removal=true','dm.use_deferred_deletion=true'],
        'docker_extra_daemon_config' => '',
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => false,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        'etcd_install_method' => 'wget',
        'etcd_package_name' => 'etcd-server',
        'etcd_version' => '3.1.12',
        'create_repos' => true,
        'docker_log_max_file' => '1',
        'docker_log_max_size' => '100m',
        }
    end
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_archive('/usr/bin/runc')}
    it { should contain_file('/usr/bin/runc')}
    it { should contain_archive('containerd-1.1.0.linux-amd64.tar.gz')}
    it { should_not contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2-00')}
    it { should contain_package('kubectl').with_ensure('1.10.2-00')}
    it { should contain_package('kubeadm').with_ensure('1.10.2-00')}
    it { should_not contain_file('/etc/docker')}
    it { should_not contain_file('/etc/docker/daemon.json').without_content(/\s*"default-runtime": "runc"\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_removal=true",\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_deletion=true"\s*/)}
    it { should_not contain_file('/etc/systemd/system/docker.service.d')}
  end

  context 'with osfamily => Debian and container_runtime => Docker and manage_docker => false and manage_etcd => true' do
    let(:facts) do
      {
        :osfamily         => 'Debian', #needed to run dependent tests from fixtures camptocamp-kmod
        :kernel           => 'Linux',
        :os               => {
          :family => "Debian",
          :name    => 'Ubuntu',
          :release => {
            :full => '16.04',
          },
          :distro => {
            :codename => "xenial",
          },
        },
      }
    end
    let(:pre_condition) {
       '
       include apt
       exec { \'kubernetes-systemd-reload\': }
       '
    }

    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
	'docker_storage_driver' => 'overlay2',
	'docker_storage_opts' => ['dm.use_deferred_removal=true','dm.use_deferred_deletion=true'],
        'docker_extra_daemon_config' => '"default-runtime": "runc"',
        'disable_swap' => true,
        'manage_docker' => false,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        'etcd_install_method' => 'wget',
        'etcd_package_name' => 'etcd-server',
        'etcd_version' => '3.1.12',
        'create_repos' => true,
        'docker_log_max_file' => '1',
        'docker_log_max_size' => '100m',
        }
    end
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
    it { should_not contain_package('docker-engine').with_ensure('17.03.0~ce-0~ubuntu-xenial')}
    it { should_not contain_file('/etc/docker')}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"default-runtime": "runc"\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_removal=true",\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_deletion=true"\s*/)}
    it { should_not contain_file('/etc/systemd/system/docker.service.d')}
  end

  context 'with disable_swap => true' do
    let(:facts) do
      {
        :osfamily         => 'Debian', #needed to run dependent tests from fixtures camptocamp-kmod
        :kernel           => 'Linux',
        :os               => {
          :family => "Debian",
          :name    => 'Ubuntu',
          :release => {
            :full => '16.04',
          },
          :distro => {
            :codename => "xenial",
          },
        },
      }
    end
    let(:pre_condition) {
       '
       include apt
       exec { \'kubernetes-systemd-reload\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2-00',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
	'docker_storage_driver' => 'overlay2',
	'docker_storage_opts' => ['dm.use_deferred_removal=true','dm.use_deferred_deletion=true'],
        'docker_extra_daemon_config' => '"default-runtime": "runc"',
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        'etcd_install_method' => 'wget',
        'etcd_package_name' => 'etcd-server',
        'etcd_version' => '3.1.12',
        'create_repos' => true,
        'docker_log_max_file' => '1',
        'docker_log_max_size' => '100m',
        }
    end
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_exec('disable swap')}
    it { should_not contain_file('/etc/docker')}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_removal=true",\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_deletion=true"\s*/)}
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"default-runtime": "runc"\s*/)}
    it { should_not contain_file('/etc/systemd/system/docker.service.d')}
  end
end
