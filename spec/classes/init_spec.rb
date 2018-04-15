require 'spec_helper'
describe 'kubernetes', :type => :class do
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

  context 'with controller => true and worker => true' do
    let(:params) do
      { 'controller' => true,
        'worker' => true,
        'kube_api_service_ip' => '10.96.0.1',
        'kube_dns_ip' => '10.96.0.10',
      }
    end

    it { should compile.and_raise_error(/A node can not be both a controller and a node/) }
   end

  context 'with controller => true' do
    let(:params) do
      { 'controller' => true,
        'kube_api_service_ip' => '10.96.0.1',
        'kube_dns_ip' => '10.96.0.10'
      }
    end

    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { should contain_class('kubernetes::config')}
    it { should contain_class('kubernetes::service')}
    it { should contain_class('kubernetes::cluster_roles')}
    it { should contain_class('kubernetes::kube_addons')}
  end

  context 'with worker => true' do
    let(:params) do
      { 'worker' => true,
        'kube_api_service_ip' => '10.96.0.1',
        'kube_dns_ip' => '10.96.0.10'
      }
    end

    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { should contain_class('kubernetes::config')}
    it { should contain_class('kubernetes::service')}
  end
end
