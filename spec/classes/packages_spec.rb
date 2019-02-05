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
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
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
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => false,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
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
        'disable_swap' => true,
        'manage_docker' => false,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
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
        'disable_swap' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'manage_kernel_modules' => true,
        'manage_sysctl_settings' => true,
        }
    end
    it { should contain_kmod__load('br_netfilter')}
    it { should contain_sysctl('net.bridge.bridge-nf-call-iptables').with_ensure('present').with_value('1')}
    it { should contain_sysctl('net.ipv4.ip_forward').with_ensure('present').with_value('1')}
    it { should contain_exec('disable swap')}
  end
end
