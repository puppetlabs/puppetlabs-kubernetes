require 'spec_helper'
describe 'kubernetes', :type => :class do
  let(:facts) do
    {
      :osfamily         => 'Debian', #needed to run dependent tests from fixtures puppetlabs-apt
      :kernel           => 'Linux',
      :os               => {
        :family => 'Debian',
        :name    => 'Ubuntu',
        :release => {
          :full => '16.04',
        },
        :distro => {
          :codename => "xenial",
        },
      },
      :ec2_metadata     => {
        :hostname => 'ip-10-10-10-1.ec2.internal',
      },
    }
  end

  context 'with controller => true and worker => true' do
    let(:params) do {
      :controller => true,
      :worker => true,
    } end

    it { should compile.and_raise_error(/A node can not be both a controller and a node/) }
   end

  context 'with controller => true' do

    let(:params) do {
      :controller => true,
    } end

    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { should contain_class('kubernetes::config::kubeadm')}
    it { should contain_class('kubernetes::service')}
    it { should contain_class('kubernetes::cluster_roles')}
    it { should contain_class('kubernetes::kube_addons')}
  end

  context 'with worker => true and version => 1.10.2' do
    let(:params) do {
      :worker => true,
    } end
                
    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { is_expected.to_not contain_class('kubernetes::config::kubeadm')}
    it { is_expected.to_not contain_class('kubernetes::config::worker')}
    it { should contain_class('kubernetes::service')}
  end

  context 'with worker => true and version => 1.12.2' do
    let(:params) do {
      :worker => true,
      :kubernetes_version => '1.12.2',
    } end
                
    it { is_expected.to_not contain_class('kubernetes::config::kubeadm')}
    it { is_expected.to contain_class('kubernetes::config::worker')}
  end

  context 'with node_label => foo and cloud_provider => undef' do
    let(:params) do {
      :worker => true,
      :node_label => 'foo',
      :cloud_provider => :undef,
    } end
                
    it { is_expected.to_not contain_notify('aws_node_name') }
  end

  context 'with node_label => foo and cloud_provider => aws' do
    let(:params) do {
      :worker => true,
      :node_label => 'foo',
      :cloud_provider => 'aws',
    } end

    it { is_expected.to contain_notify('aws_name_override') }
  end

  context 'with node_label => undef and cloud_provider => aws' do
    let(:params) do {
      :worker => true,
      :node_label => :undef,
      :cloud_provider => 'aws',
    } end

    it { is_expected.to_not contain_notify('aws_name_override') }
  end
end
