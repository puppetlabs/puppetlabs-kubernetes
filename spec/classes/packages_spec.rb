# frozen_string_literal: true

require 'spec_helper'
describe 'kubernetes::packages', type: :class do
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
        osfamily: 'RedHat', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.4'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'docker\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.5.0',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'pin_packages' => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_package('docker-engine').with_ensure('17.03.1.ce-1.el7.centos') }
    it { is_expected.to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.to contain_file('/etc/docker') }
    it { is_expected.to contain_file('/etc/docker/daemon.json') }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_removal=true",\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_deletion=true"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=systemd"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/docker.service.d') }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/docker') }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/kubernetes') }

    it '/etc/docker/daemon.json should be valid JSON' do
      require 'json'
      json_data = catalogue
                  .resource('file', '/etc/docker/daemon.json')
                  .send(:parameters)[:content]
      puts json_data
      expect { JSON.parse(json_data) }.not_to raise_error
    end
  end

  context 'with osfamily => RedHat and container_runtime => Docker and manage_docker => true and manage_etcd => true and etcd_install_method => package' do
    let(:facts) do
      {
        osfamily: 'RedHat', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.4'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'docker\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'pin_packages' => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_package('docker-engine').with_ensure('17.03.1.ce-1.el7.centos') }
    it { is_expected.not_to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('etcd-server').with_ensure('3.1.12') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.to contain_file('/etc/docker') }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dummy": "dummy"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_removal=true",\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_deletion=true"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=cgroupfs"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/docker.service.d') }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/docker') }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/kubernetes') }

    it '/etc/docker/daemon.json should be valid JSON' do
      require 'json'
      json_data = catalogue
                  .resource('file', '/etc/docker/daemon.json')
                  .send(:parameters)[:content]
      expect { JSON.parse(json_data) }.not_to raise_error
    end
  end

  context 'with osfamily => RedHat and container_runtime => cri_containerd and containerd_install_method => package and manage_etcd => true' do
    let(:facts) do
      {
        osfamily: 'RedHat', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.4'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'package',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'pin_packages' => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          },
          'docker.private.example.com' => {
            'mirrors' => {},
            'tls' => {
              'ca_file' => 'ca1.pem',
              'cert_file' => 'cert1.pem',
              'key_file' => 'key1.pem'
            },
            'auth' => {
              'auth' => '1azhzLXVuaXQtdGVzdDpCQ0NwNWZUUXlyd3c1aUxoMXpEQXJnUT=='
            }
          },
          'docker.more-private.example.com' => {
            'mirrors' => {
              'endpoint' => 'https://docker.more-private.example.com'
            },
            'tls' => {
              'insecure_skip_verify' => true
            },
            'auth' => {
              'username' => 'user2',
              'password' => 'secret2'
            }
          },
          'docker.even-more-private.example.com' => {
            'mirrors' => {
              'endpoint' => 'https://docker.even-more-private.example.com'
            },
            'tls' => {
              'ca_file' => 'ca2.pem'
            },
            'auth' => {
              'identitytoken' => 'azhzLXVuaXQtdGVzdDpCQ0NwNWZUUXlyd3c1aUxoMXpEQXJnUT'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_package('containerd.io').with_ensure('1.4.3') }
    it { is_expected.to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.to contain_file('/etc/containerd') }
    it { is_expected.to contain_file('/etc/containerd/config.toml').without_source }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*endpoint = \["https://registry-1.docker.io"\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').without_content(
        %r{\s*\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.private.example.com"\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.even-more-private.example.com"\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*endpoint = \["https://docker.even-more-private.example.com"\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*\[plugins."io.containerd.grpc.v1.cri".registry.configs."docker.private.example.com".auth\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*auth = "1azhzLXVuaXQtdGVzdDpCQ0NwNWZUUXlyd3c1aUxoMXpEQXJnUT=="\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*username = "user2"\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*password = "secret2"\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*identitytoken = "azhzLXVuaXQtdGVzdDpCQ0NwNWZUUXlyd3c1aUxoMXpEQXJnUT"\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*\[plugins."io.containerd.grpc.v1.cri".registry.configs."docker.private.example.com".tls\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*ca_file = "ca1.pem"\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*cert_file = "cert1.pem"\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*key_file = "key1.pem"\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*insecure_skip_verify = true\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*ca_file = "ca2.pem"\s*},
      )
    }

    it { is_expected.not_to contain_file('/etc/apt/preferences.d/containerd') }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\saddress = "/run/containerd/containerd.sock"},
      )
    }
  end

  context 'with osfamily => RedHat and container_runtime => cri_containerd and containerd_install_method => package and containerd_default_runtime_name => nvidia and manage_etcd => true' do
    let(:facts) do
      {
        osfamily: 'RedHat', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.4'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.1.ce-1.el7.centos',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'package',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'nvidia',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'pin_packages' => false,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes'
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_package('containerd.io').with_ensure('1.4.3') }
    it { is_expected.to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.to contain_file('/etc/containerd') }
    it { is_expected.to contain_file('/etc/containerd/config.toml').without_source }
    it { is_expected.to contain_file('/etc/containerd/config.toml').with_content(%r{default_runtime_name = "nvidia"}) }
    it { is_expected.to contain_file('/etc/containerd/config.toml').with_content(%r{plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia}) }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/containerd') }
  end

  context 'with osfamily => Debian and container_runtime => cri_containerd and manage_etcd => false' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2-00',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_archive('/usr/bin/runc') }
    it { is_expected.to contain_file('/usr/bin/runc') }
    it { is_expected.to contain_archive('containerd-1.4.3-linux-amd64.tar.gz') }
    it { is_expected.not_to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2-00') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2-00') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2-00') }
    it { is_expected.not_to contain_file('/etc/docker') }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').without_content(%r{\s*"default-runtime": "runc"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_removal=true",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_deletion=true"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=systemd"\s*}) }
    it { is_expected.not_to contain_file('/etc/systemd/system/docker.service.d') }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/docker') }
    it { is_expected.to contain_file('/etc/apt/preferences.d/kubernetes') }
  end

  context 'with osfamily => Debian and container_runtime => Docker and manage_docker => true and manage_etcd => true' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'docker\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end

    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
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
        'pin_packages' => true,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.to contain_package('docker-engine').with_ensure('17.03.0~ce-0~ubuntu-xenial') }
    it { is_expected.to contain_file('/etc/docker') }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"default-runtime": "runc"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=systemd"\s*}) }
    it { is_expected.to contain_file('/etc/apt/preferences.d/docker') }

    it '/etc/docker/daemon.json should be valid JSON' do
      require 'json'
      json_data = catalogue
                  .resource('file', '/etc/docker/daemon.json')
                  .send(:parameters)[:content]
      expect { JSON.parse(json_data) }.not_to raise_error
    end
  end

  context 'container_runtime => Docker and manage_docker => true and container_runtime_use_proxy => true' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'docker\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end

    let(:params) do
      {
        'container_runtime' => 'docker',
        'container_runtime_use_proxy' => true,
        'http_proxy' => 'foo',
        'https_proxy' => 'bar',
        'no_proxy' => 'baz',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
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
        'pin_packages' => true,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file('/etc/systemd/system/docker.service.d') }
    it { is_expected.to contain_file('/etc/systemd/system/docker.service.d/http-proxy.conf').with_content(%r{\s*Environment="HTTP_PROXY=foo"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/docker.service.d/http-proxy.conf').with_content(%r{\s*Environment="HTTPS_PROXY=bar"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/docker.service.d/http-proxy.conf').with_content(%r{\s*Environment="NO_PROXY=baz"\s*}) }
    it { is_expected.not_to contain_file('/etc/systemd/system/containerd.service.d') }
    it { is_expected.not_to contain_file('/etc/systemd/system/containerd.service.d/http-proxy.conf') }
  end

  context 'with osfamily => Debian and container_runtime => Docker and manage_docker => false and manage_etcd => true' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end

    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.not_to contain_package('docker-engine').with_ensure('17.03.0~ce-0~ubuntu-xenial') }
    it { is_expected.not_to contain_file('/etc/docker') }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"default-runtime": "runc"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_removal=true",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_deletion=true"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=systemd"\s*}) }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/docker') }
    it { is_expected.to contain_file('/etc/apt/preferences.d/kubernetes') }
  end

  context 'with osfamily => Debian and container_runtime => cri_containerd and containerd_install_method => package and manage_etcd => true' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end

    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'package',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
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
        'pin_packages' => true,
        'containerd_archive_checksum' => nil,
        'etcd_archive_checksum' => nil,
        'runc_source_checksum' => nil,
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_archive('etcd-v3.1.12-linux-amd64.tar.gz') }
    it { is_expected.to contain_package('kubelet').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubectl').with_ensure('1.10.2') }
    it { is_expected.to contain_package('kubeadm').with_ensure('1.10.2') }
    it { is_expected.to contain_package('containerd.io').with_ensure('1.4.3') }
    it { is_expected.to contain_file('/etc/containerd') }
    it { is_expected.to contain_file('/etc/containerd/config.toml') }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*\[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"\]\s*},
      )
    }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\s*endpoint = \["https://registry-1.docker.io"\]\s*},
      )
    }
    # it { should contain_file('/etc/apt/preferences.d/containerd')}
  end

  context 'with disable_swap => true' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.10.2-00',
        'docker_version' => '17.03.0~ce-0~ubuntu-xenial',
        'containerd_version' => '1.4.3',
        'containerd_install_method' => 'archive',
        'containerd_package_name' => 'containerd.io',
        'containerd_archive' => 'containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_source' => 'https://github.com/containerd/containerd/releases/download/v1.4.3/containerd-1.4.3-linux-amd64.tar.gz',
        'containerd_config_template' => 'kubernetes/containerd/config.toml.epp',
        'containerd_default_runtime_name' => 'runc',
        'etcd_archive' => 'etcd-v3.1.12-linux-amd64.tar.gz',
        'etcd_source' => 'https://github.com/etcd-v3.1.12.tar.gz',
        'runc_source' => 'https://github.com/runcsource',
        'controller' => true,
        'docker_package_name' => 'docker-engine',
        'docker_storage_driver' => 'overlay2',
        'docker_storage_opts' => ['dm.use_deferred_removal=true', 'dm.use_deferred_deletion=true'],
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
        'pin_packages' => true,
        'containerd_archive_checksum' => 'bcab421f6bf4111accfceb004e0a0ac2bcfb92ac93081d9429e313248dd78c41',
        'etcd_archive_checksum' => 'bcab421f6bf4111accfceb004e0a0ac2bcfb92ac93081d9429e313248dd78c41',
        'runc_source_checksum' => 'bcab421f6bf4111accfceb004e0a0ac2bcfb92ac93081d9429e313248dd78c41',
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_plugins_registry' => {
          'docker.io' => {
            'mirrors' => {
              'endpoint' => 'https://registry-1.docker.io'
            }
          }
        }
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_exec('disable swap') }
    it { is_expected.not_to contain_file('/etc/docker') }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_removal=true",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_deletion=true"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"default-runtime": "runc"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=systemd"\s*}) }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/docker') }
    it { is_expected.to contain_file('/etc/apt/preferences.d/kubernetes') }
    it { is_expected.not_to contain_file('/etc/systemd/system/docker.service.d') }
  end

  context 'on Debian 11' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppet-kmod
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Debian',
          release: {
            full: '11.4',
            major: '11'
          },
          distro: {
            codename: 'bullseye'
          }
        }
      }
    end
    let(:pre_condition) do
      '
       include apt
       include kubernetes
       exec { \'kubernetes-systemd-reload\': }
       service { \'etcd\': }
       service { \'containerd\': }
       '
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_package_version' => '1.24.3-00',
        'containerd_version' => '1.6.6',
        'etcd_version' => '3.4.19',
        'runc_source' => 'https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64',
        'containerd_install_method' => 'archive',
        'containerd_default_runtime_name' => 'runc',
        'controller' => true,
        'docker_cgroup_driver' => 'systemd',
        'disable_swap' => true,
        'manage_docker' => false,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        'etcd_install_method' => 'wget',
        'etcd_package_name' => 'etcd-server',
        'create_repos' => true,
        'pin_packages' => true,
        'containerd_archive_checksum' => '0212869675742081d70600a1afc6cea4388435cc52bf5dc21f4efdcb9a92d2ef',
        'etcd_archive_checksum' => '9ba70e27c17a1faf6d3de89040432189d8071fa27ca156d09d3503989ecd9ccd',
        'runc_source_checksum' => '6e8b24be90fffce6b025d254846da9d2ca6d65125f9139b6354bab0272253d01',
        'tmp_directory' => '/var/tmp/puppetlabs-kubernetes',
        'containerd_socket' => 'unix:///run/containerd/containerd.sock'
      }
    end

    it { is_expected.to contain_file_line('remove swap in /etc/fstab') }
    it { is_expected.to contain_kmod__load('overlay') }
    it { is_expected.to contain_kmod__load('br_netfilter') }
    it { is_expected.to contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1') }
    it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1') }
    it { is_expected.to contain_exec('disable swap') }
    it { is_expected.to contain_file('/etc/containerd/config.toml').with_content(%r{\s*SystemdCgroup = true\s*}) }
    it { is_expected.to contain_file('/usr/bin/runc').with_mode('0700') }
    it { is_expected.not_to contain_file('/etc/docker') }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-driver": "overlay2",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"storage-opts"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_removal=true",\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"dm.use_deferred_deletion=true"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"default-runtime": "runc"\s*}) }
    it { is_expected.not_to contain_file('/etc/docker/daemon.json').with_content(%r{\s*"native.cgroupdriver=systemd"\s*}) }
    it { is_expected.not_to contain_file('/etc/apt/preferences.d/docker') }
    it { is_expected.to contain_file('/etc/apt/preferences.d/kubernetes') }
    it { is_expected.not_to contain_file('/etc/systemd/system/docker.service.d') }

    it {
      expect(subject).to contain_file('/etc/containerd/config.toml').with_content(
        %r{\saddress = "unix:///run/containerd/containerd.sock"},
      )
    }
  end
end
