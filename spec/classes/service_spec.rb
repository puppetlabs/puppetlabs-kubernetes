require 'spec_helper'
describe 'kubernetes::service', :type => :class do
  let(:facts) do
    {
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
  context 'with defaults for all params' do
    let(:params) do
      {
        'container_runtime' => 'docker',
	'controller' => false,
        'bootstrap_controller' => false,
        'etcd_ip' => '127.0.0.1',
        'cni_network_provider' => 'https://foo.test',
      }
    end

   it { should contain_service('docker') }
   it { should contain_file('/etc/systemd/system/kubelet.service.d') }
   it { should contain_file('/etc/systemd/system/kubelet.service.d/kubernetes.conf').with_content(/Environment="KUBELET_NETWORK_ARGS/) }
   it { should contain_exec('Reload systemd') }
   it { should contain_service('kubelet') }
  end

  context 'with bootstrap_controller => yes' do
    let(:params) do
      {
        'container_runtime' => 'docker',
	'bootstrap_controller' => true,
        'controller' => true,
        'etcd_ip' => '127.0.0.1',
        'cni_network_provider' => 'https://foo.test',
      }
    end

    it { should contain_exec('Checking for the Kubernets cluster to be ready')}
  end

  context 'with cni_network_provider => none' do
    let(:params) do
      {
        'container_runtime' => 'docker',
        'controller' => false,
        'bootstrap_controller' => false,
        'etcd_ip' => '127.0.0.1',
        'cni_network_provider' => 'none',
      }
    end

   it { should contain_file('/etc/systemd/system/kubelet.service.d/kubernetes.conf').without_content(/Environment="KUBELET_NETWORK_ARGS/) }
  end
end
