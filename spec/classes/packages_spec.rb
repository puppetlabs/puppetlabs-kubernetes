require 'spec_helper'
describe 'kubernetes::packages', :type => :class do
  let(:facts) { { :osfamily => 'Debian' } }
  let(:params) do
    {
      'kubernetes_package_version' => '1.7.3-01',
      'cni_version' => '0.5.1-00',
    }
  end

  context 'with defaults for params and osfamily => Debian' do

    it { should contain_package('docker-engine').with_ensure('1.12.0-0~xenial')}
    it { should contain_package('kubelet').with_ensure('1.7.3-01')}
    it { should contain_package('kubectl').with_ensure('1.7.3-01')}
    it { should contain_package('kubernetes-cni').with_ensure('0.5.1-00')}
  end
end
