require 'spec_helper'
describe 'kubernetes::packages', :type => :class do
  let(:facts) { { :osfamily => 'Debian' } }
  let(:params) do
    {
      'container_runtime' => 'docker',
      'kubernetes_package_version' => '1.9.2-00',
      'cni_version' => '0.6.0-00',
    }
  end

  context 'with defaults for params and osfamily => Debian' do

    it { should contain_package('docker-engine').with_ensure('1.12.0-0~xenial')}
    it { should contain_package('kubelet').with_ensure('1.9.2-00')}
    it { should contain_package('kubectl').with_ensure('1.9.2-00')}
    it { should contain_package('kubernetes-cni').with_ensure('0.6.0-00')}
  end
end
