require 'spec_helper'
describe 'kubernetes::repos', :type => :class do
  context 'with osfamily => Ubuntu' do
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily => 'Debian',
        :os               => {
          :name    => 'Ubuntu',
          :release => {
            :full => '16.04',
          },
        },
      }
    end

    let(:params) { { 'manage_epel' => false } }

    it { should contain_apt__source('kubernetes') }
    it { should contain_apt__source('docker') }

  end

  context 'with osfamily => RedHat and manage_epel => true' do
    let(:facts) do
      {
        :operatingsystem => 'RedHat',
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7.0',
      }
    end

    let(:params) { { 'manage_epel' => true } }

    it { should contain_class('epel') }
    it { should contain_yumrepo('docker') }
    it { should contain_yumrepo('kubernetes') }
  end
end