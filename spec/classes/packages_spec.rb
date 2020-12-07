require 'spec_helper'
describe 'kubernetes::packages', :type => :class do
  let(:pre_condition) do
      [
      'include kubernetes',
      'include kubernetes::config::kubeadm',
      'exec { \'kubernetes-systemd-reload\': }',
      'archive{ \'etcd-archive\': }',
      ]
  end
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
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
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages'  => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
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
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"native.cgroupdriver=systemd"\s*/)}
    it { should contain_file('/etc/systemd/system/docker.service.d')}
    it { should_not contain_file('/etc/apt/preferences.d/docker')}
    it { should_not contain_file('/etc/apt/preferences.d/kubernetes')}
    it '/etc/docker/daemon.json should be valid JSON' do
      require 'json'
      json_data = catalogue
        .resource('file', '/etc/docker/daemon.json')
        .send(:parameters)[:content]
      puts json_data
      expect { JSON.parse(json_data) }.to_not raise_error
    end
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true','dm.use_deferred_deletion=true'],
        'docker_extra_daemon_config' => '"dummy": "dummy"',
        'docker_cgroup_driver' => 'cgroupfs',
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
        'pin_packages'  => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
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
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dummy": "dummy"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_removal=true",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"dm.use_deferred_deletion=true"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"native.cgroupdriver=cgroupfs"\s*/)}
    it { should contain_file('/etc/systemd/system/docker.service.d')}
    it { should_not contain_file('/etc/apt/preferences.d/docker')}
    it { should_not contain_file('/etc/apt/preferences.d/kubernetes')}
    it '/etc/docker/daemon.json should be valid JSON' do
      require 'json'
      json_data = catalogue
        .resource('file', '/etc/docker/daemon.json')
        .send(:parameters)[:content]
      expect { JSON.parse(json_data) }.to_not raise_error
    end
  end

  context 'with osfamily => RedHat and container_runtime => cri_containerd and containerd_install_method => package and manage_etcd => true' do
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'package',
        'containerd_package_name' => 'containerd.io',
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
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages'  => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_package('containerd.io').with_ensure('1.1.0')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
    it { should contain_file('/etc/containerd')}
    it { should contain_file('/etc/containerd/config.toml')}
    it { should_not contain_file('/etc/apt/preferences.d/containerd')}
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2-00',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
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
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages' => true,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
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
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"native.cgroupdriver=systemd"\s*/)}
    it { should_not contain_file('/etc/systemd/system/docker.service.d')}
    it { should_not contain_file('/etc/apt/preferences.d/docker')}
    it { should contain_file('/etc/apt/preferences.d/kubernetes')}
  end

  context 'with osfamily => Debian and container_runtime => Docker and manage_docker => true and manage_etcd => true' do
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
       service { \'docker\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }

    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => [],
        'docker_extra_daemon_config' => '"default-runtime": "runc"',
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages'  => true,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
    it { should contain_package('docker-engine').with_ensure('17.03.0~ce-0~ubuntu-xenial')}
    it { should contain_file('/etc/docker')}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"default-runtime": "runc"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-driver": "overlay2",\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"storage-opts"\s*/)}
    it { should contain_file('/etc/docker/daemon.json').with_content(/\s*"native.cgroupdriver=systemd"\s*/)}
    it { should contain_file('/etc/apt/preferences.d/docker')}
    it '/etc/docker/daemon.json should be valid JSON' do
      require 'json'
      json_data = catalogue
        .resource('file', '/etc/docker/daemon.json')
        .send(:parameters)[:content]
      expect { JSON.parse(json_data) }.to_not raise_error
    end
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }

    let(:params) do
        {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
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
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages' => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
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
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"native.cgroupdriver=systemd"\s*/)}
    it { should_not contain_file('/etc/apt/preferences.d/docker')}
    it { should contain_file('/etc/apt/preferences.d/kubernetes')}
  end

  context 'with osfamily => Debian and container_runtime => cri_containerd and containerd_install_method => package and manage_etcd => true' do
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }

    let(:params) do
        {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'package',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' =>'containerd-1.1.0.linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd-1.1.0.linux-amd64.tar.gz',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => [],
        'docker_extra_daemon_config' => '"default-runtime": "runc"',
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages'  => true,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
    it { should contain_package('containerd.io').with_ensure('1.1.0')}
    it { should contain_file('/etc/containerd')}
    it { should contain_file('/etc/containerd/config.toml')}
    it { should contain_file('/etc/apt/preferences.d/containerd')}
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
       service { \'etcd\': }
       service { \'containerd\': }
       '
    }
    let(:params) do
        {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2-00',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.1.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
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
        'docker_cgroup_driver' => 'systemd',
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
        'pin_packages'  => true,
        'containerd_archive_checksum' => 'bcab421f6bf4111accfceb004e0a0ac2bcfb92ac93081d9429e313248dd78c41',
        'etcd_archive_checksum' => 'bcab421f6bf4111accfceb004e0a0ac2bcfb92ac93081d9429e313248dd78c41',
        'runc_source_checksum' => 'bcab421f6bf4111accfceb004e0a0ac2bcfb92ac93081d9429e313248dd78c41',
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        }
    end
    it { should contain_file_line('remove swap in /etc/fstab')}
    it { should contain_kmod__load('overlay')}
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
    it { should_not contain_file('/etc/docker/daemon.json').with_content(/\s*"native.cgroupdriver=systemd"\s*/)}
    it { should_not contain_file('/etc/apt/preferences.d/docker')}
    it { should contain_file('/etc/apt/preferences.d/kubernetes')}
    it { should_not contain_file('/etc/systemd/system/docker.service.d')}
  end
end
