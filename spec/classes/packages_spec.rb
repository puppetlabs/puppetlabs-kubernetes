require 'spec_helper'
describe 'kubernetes::packages', :type => :class do
  context 'with osfamily => RedHat and container_runtime => Docker' do
    let(:facts) do
        {
          :kernel           => 'Linux',
          :osfamily         => 'RedHat',
          :operatingsystem  => 'RedHat',
          :os               => {
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
        }
    end

    it { should contain_exec('set up bridge-nf-call-iptables')}
    it { should contain_file_line('set 1 /proc/sys/net/bridge/bridge-nf-call-iptables')}
    it { should contain_package('docker-engine').with_ensure('17.03.1.ce-1.el7.centos')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2')}
    it { should contain_package('kubectl').with_ensure('1.10.2')}
    it { should contain_package('kubeadm').with_ensure('1.10.2')}
  end

  context 'with osfamily => Debian and container_runtime => cri_containerd' do
    let(:facts) do
        {
          :kernel           => 'Linux',
          :osfamily         => 'Debian',
          :operatingsystem  => 'Ubuntu',
          :os               => {
            :name    => 'Ubuntu',
            :release => {
              :full => '16.04',
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
        }
    end

    it { should contain_wget__fetch("download runc binary")}
    it { should contain_file('/usr/bin/runc')}
    it { should contain_archive('containerd-1.1.0.linux-amd64.tar.gz')}
    it { should contain_archive('etcd-v3.1.12-linux-amd64.tar.gz')}
    it { should contain_package('kubelet').with_ensure('1.10.2-00')}
    it { should contain_package('kubectl').with_ensure('1.10.2-00')}
    it { should contain_package('kubeadm').with_ensure('1.10.2-00')}
    
  end
end
