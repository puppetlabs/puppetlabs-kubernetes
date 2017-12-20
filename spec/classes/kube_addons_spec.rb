require 'spec_helper'
describe 'kubernetes::kube_addons', :type => :class do
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

  context 'with bootstrap_controller => true' do
    let(:params) do {
      'bootstrap_controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'kubernetes_version' => '1.7.3'
      }
    end

    it { should contain_exec('Install cni network provider') }
    it { should contain_exec('Create kube proxy service account') }
    it { should contain_exec('Create kube proxy ConfigMap') }
    it { should contain_exec('Create kube proxy daemonset') }
    it { should contain_exec('Create kube dns service account') }
    it { should contain_exec('Create kube dns service') }
    it { should contain_exec('Create kube dns deployment') }
  end

  context 'with install_dashboard => true' do
    let(:params) do {
      'bootstrap_controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => true,
      'kubernetes_version' => '1.7.3'
      }
    end

    it { should contain_exec('Install Kubernetes dashboard')}
  end

  context 'with cni_network_provider => none' do
    let(:params) do {
      'bootstrap_controller' => true,
      'cni_network_provider' => 'none',
      'install_dashboard' => false,
      'kubernetes_version' => '1.7.3'
      }
    end

    it { should_not contain_exec('Install cni network provider') }
  end
end
