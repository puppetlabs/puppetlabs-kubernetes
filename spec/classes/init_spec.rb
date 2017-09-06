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
        'worker' => true
      }
    end

    it { should compile.and_raise_error(/A node can not be both a controller and a node/) }
   end

  context 'with controller => true' do
    let(:params) do
      { 'controller' => true }
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
      { 'worker' => true}
    end

    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { should contain_class('kubernetes::config')}
    it { should contain_class('kubernetes::service')}
  end
end