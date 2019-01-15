require 'spec_helper'
describe 'kubernetes::config::worker', :type => :class do
  let(:pre_condition) { 'include kubernetes' }
  let(:facts) do
    {
      :kernel => 'Linux',
      :networking => {
        :hostname => 'foo',
      },
      :os => {
        :family => 'Debian',
        :name => 'Ubuntu',
        :release => {
          :full => '16.04',
        },
        :distro => {
          :codename => 'xenial',
        },
      },
      :ec2_metadata => {
        :hostname => 'ip-10-10-10-1.ec2.internal',
      },
    }
  end

  context 'with version => 1.12.3 cloud_provider => undef' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'kubelet_extra_arguments' => ['foo'],
      }
    end

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{apiVersion: kubeadm.k8s.io/v1alpha3\n}) }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{  kubeletExtraArgs:\n    foo\n}) }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').without_content(%r{cloud-provider}) }
  end

  context 'with version => 1.12.3 cloud_provider => aws' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'cloud_provider' => 'aws',
      }
    end

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{apiVersion: kubeadm.k8s.io/v1alpha3\n}) }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{  kubeletExtraArgs:\n    cloud-provider: aws\n}) }
  end
end
