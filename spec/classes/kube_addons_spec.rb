require 'spec_helper'
describe 'kubernetes::kube_addons', :type => :class do
  let(:facts) do
    {
      :lsbdistcodename  => 'xenial',
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

  context 'with controller => true and schedule_on_controller => true' do
    let(:params) do {
      'controller' => true,
      'cni_rbac_binding' => 'foo',
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'kubernetes_version' => '1.10.2',
      'schedule_on_controller' => true,
      'node_label' => 'foo',
      }
    end

    it { should contain_exec('Install calico rbac bindings')}
    it { should contain_exec('Install cni network provider')}
    it { should contain_exec('schedule on controller')}
  end

  context 'with install_dashboard => true' do
    let(:params) do {
      'controller' => true,
      'cni_rbac_binding' => nil,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => true,
      'kubernetes_version' => '1.10.2',
      'schedule_on_controller' => false,
      'node_label' => 'foo',
      }
    end
    it { should contain_exec('Install Kubernetes dashboard')}
  end
end
