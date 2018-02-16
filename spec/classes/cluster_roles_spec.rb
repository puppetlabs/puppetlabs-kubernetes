require 'spec_helper'
describe 'kubernetes::cluster_roles', :type => :class do
  let(:params) { { 'bootstrap_controller' => true, 'kubernetes_version' => '1.7.3' } }


  context 'with bootstrap_controller => true' do
    let(:pre_condition) { 'include kubernetes::config'}
	  let(:params) { { 'bootstrap_controller' => true, 'kubernetes_version' => '1.7.3' } }

      it { should contain_exec('Create kube bootstrap token') }
      it { should contain_exec('Create kube proxy cluster bindings') }
  end
end
