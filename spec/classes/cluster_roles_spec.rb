require 'spec_helper'
describe 'kubernetes::cluster_roles', :type => :class do

  context 'with bootstrap_controller => true' do
    let(:params) { { 'bootstrap_controller' => true } }

      it { should contain_exec('Create kube bootstrap token') }
      it { should contain_exec('Create kube proxy cluster bindings') }
  end
end