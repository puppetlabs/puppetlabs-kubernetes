require 'spec_helper'
describe 'kubernetes::kube_addons', :type => :class do
  let (:pre_condition) { 'include kubernetes::config'}
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
      'kubernetes_version' => '1.7.3',
      'controller' => true,
      'taint_master' => true
      }
    end

    it { should contain_exec('Install cni network provider') }
    it { should contain_exec('Create kube proxy service account') }
    it { should contain_exec('Create kube proxy ConfigMap') }
    it { should contain_exec('Create kube proxy daemonset') }
    it { should contain_exec('Create kube dns service account') }
    it { should contain_exec('Create kube dns service') }
    it { should contain_exec('Create kube dns deployment') }
    it { should contain_exec('Assign master role to controller') }
    it { should contain_exec('Checking for dns to be deployed') }
    it { should contain_exec('Taint master node') }
  end

  context 'with controller => true and taint_master => true' do
    let(:params) do {
      'bootstrap_controller' => false,
      'controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'kubernetes_version' => '1.7.3',
      'taint_master' => true
      }
    end
    it { should contain_exec('Checking for dns to be deployed') }
    it { should contain_exec('Taint master node') }
  end

  context 'with install_dashboard => true' do
    let(:params) do {
      'bootstrap_controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => true,
      'kubernetes_version' => '1.7.3',
      'controller' => true,
      'taint_master' => false
      }
    end

    it { should contain_exec('Install Kubernetes dashboard')}
  end
end
