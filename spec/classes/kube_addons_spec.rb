require 'spec_helper'
describe 'kubernetes::kube_addons', :type => :class do
  let(:pre_condition) { 'include kubernetes' }
  let(:facts) do
    {
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
  context 'with controller => true and schedule_on_controller => true' do
    let(:params) do {
      'controller' => true,
      'cni_rbac_binding' => 'foo',
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'dashboard_version' => 'v1.10.1',
      'kubernetes_version' => '1.10.2',
      'schedule_on_controller' => true,
      'node_name' => 'foo',
      }
    end

    it { should contain_exec('Install calico rbac bindings')}
    it { should contain_exec('Install cni network provider')}
    it { should contain_exec('schedule on controller')}

    it { should_not contain_exec('Install cni network (preinstall)')}
    it { should_not contain_file('/etc/kubernetes/calico-installation.yaml')}
    it { should_not contain_file_line('Configure calico ipPools.cidr')}
  end

  context 'with cni_provider => calico' do
    let(:params) do {
      'controller' => true,
      'cni_network_preinstall' => 'https://foo.test/tigera-operator',
      'cni_network_provider' => 'https://foo.test',
      'cni_provider' => 'calico',
      'install_dashboard' => false,
      'dashboard_version' => 'v1.10.1',
      'kubernetes_version' => '1.10.2',
      'node_name' => 'foo',
      }
    end

    it { should contain_exec('Install cni network (preinstall)')}
    it { should contain_file('/etc/kubernetes/calico-installation.yaml')}
    it { should contain_file_line('Configure calico ipPools.cidr')}
    it { should contain_exec('Install cni network provider')}
  end

  context 'with install_dashboard => false' do
    let(:params) do {
      'controller' => true,
      'cni_rbac_binding' => nil,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'kubernetes_version' => '1.10.2',
      'dashboard_version' => 'v1.10.1',
      'schedule_on_controller' => false,
      'node_name' => 'foo',
      }
    end
    it { is_expected.to_not contain_exec('Install Kubernetes dashboard')}
  end

  context 'with install_dashboard => true' do
    let(:params) do {
      'controller' => true,
      'cni_rbac_binding' => nil,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => true,
      'kubernetes_version' => '1.10.2',
      'dashboard_version' => 'v1.10.1',
      'schedule_on_controller' => false,
      'node_name' => 'foo',
      }
    end
    it { is_expected.to contain_exec('Install Kubernetes dashboard').with_command(%r{dashboard/v1.10.1/src}) }
  end
end
