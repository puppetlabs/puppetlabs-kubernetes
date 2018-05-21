require 'spec_helper'
describe 'kubernetes::repos', :type => :class do

  
  context 'with osfamily => Ubuntu' do
    let(:pre_condition) { 'class {"kubernetes":
      docker_repo_name => "docker",
      kube_dns_ip => "10.96.0.10",
      kube_api_service_ip => "10.96.0.1" }
    '}
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

    let(:params) { { 'container_runtime' => 'docker' } }

    it { should contain_apt__source('kubernetes').with(
      :ensure   => 'present',
      :location => 'http://apt.kubernetes.io',
      :repos    => 'main',
      :release  => 'kubernetes-xenial',
      :key      => { 'id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB', 'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg' }
    ) }

    it { should contain_apt__source('docker').with(
      :ensure   => 'present',
      :location => 'https://apt.dockerproject.org/repo',
      :repos    => 'main',
      :release  => 'ubuntu-xenial',
      :key      => { 'id' => '58118E89F3A912897C070ADBF76221572C52609D', 'source' => 'https://apt.dockerproject.org/gpg' }
    ) }

  end

  context 'with osfamily => Ubuntu and docker_repo_name => docker_kubernetes' do
    let(:pre_condition) { 'class {"kubernetes":
      docker_repo_name => "docker",
      kube_dns_ip => "10.96.0.10",
      kube_api_service_ip => "10.96.0.1" }
    '}
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

    let(:params) do 
      { 
        'container_runtime' => 'docker',
        'docker_repo_name'  => 'docker_kubernetes',
      
      }
    end

    it { should contain_apt__source('kubernetes').with(
      :ensure   => 'present',
      :location => 'http://apt.kubernetes.io',
      :repos    => 'main',
      :release  => 'kubernetes-xenial',
      :key      => { 'id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB', 'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg' }
    ) }

    it { should contain_apt__source('docker_kubernetes').with(
      :ensure   => 'present',
      :location => 'https://apt.dockerproject.org/repo',
      :repos    => 'main',
      :release  => 'ubuntu-xenial',
      :key      => { 'id' => '58118E89F3A912897C070ADBF76221572C52609D', 'source' => 'https://apt.dockerproject.org/gpg' }
    ) }

  end

  context 'with osfamily => RedHat and manage_epel => true' do
    let(:pre_condition) { 'class {"kubernetes":
      docker_repo_name => "docker",
      kube_dns_ip => "10.96.0.10",
      kube_api_service_ip => "10.96.0.1" }
    '}
    let(:facts) do
      {
        :operatingsystem => 'RedHat',
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7.0',
      }
    end

    let(:params) { { 'container_runtime' => 'docker' } }

    it { should contain_yumrepo('docker') }
    it { should contain_yumrepo('kubernetes') }
  end

  context 'with osfamily => RedHat and docker_repo_name => docker_kubernetes' do
    let(:pre_condition) { 'class {"kubernetes":
      docker_repo_name => "docker",
      kube_dns_ip => "10.96.0.10",
      kube_api_service_ip => "10.96.0.1" }
    '}
    let(:facts) do
      {
        :operatingsystem => 'RedHat',
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7.0',
      }
    end

    let(:params) do 
      { 
        'container_runtime' => 'docker',
        'docker_repo_name'  => 'docker_kubernetes',
      
      }
    end

    it { should contain_yumrepo('docker_kubernetes') }
    it { should contain_yumrepo('kubernetes') }
  end
end
