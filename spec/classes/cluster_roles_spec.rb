require 'spec_helper'
describe 'kubernetes::cluster_roles', :type => :class do
  let(:facts) do {
    :kernel => 'Linux',
    :networking => {
      :hostname => 'foo',
    },
    :os => {
      :family => "Debian",
      :name => 'Ubuntu',
      :release => {
        :full => '16.04',
      },
      :distro => {
        :codename => "xenial",
      },
    },
    :networking => {
      :hostname => 'foo',
    },
    :ec2_metadata => {
      :hostname => 'ip-10-10-10-1.ec2.internal',
    },
  } end

  context 'with controller => true' do
    let(:pre_condition) { 'include kubernetes' }
    let(:params) do 
        { 
          'controller' => true, 
          'worker' => false,
        } 
    end

    it { should contain_kubernetes__kubeadm_init('foo') }
  end

  context 'with worker => true' do
    let(:pre_condition) { 'include kubernetes' }
    let(:params) do 
        { 
          'controller' => false, 
          'worker' => true,
        } 
    end

    it { should contain_kubernetes__kubeadm_join('foo') }
  end
end
