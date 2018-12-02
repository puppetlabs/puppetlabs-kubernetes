require 'spec_helper'
describe 'kubernetes::repos', :type => :class do

  
  context 'with osfamily => Ubuntu and manage_docker => true' do
    let(:facts) do
      {
        :osfamily         => 'Debian', #needed to run dependent tests from fixtures puppetlabs-apt
        :kernel           => 'Linux',
        :os               => {
          :family => 'Debian',
          :name   => 'Ubuntu',
          :release => {
            :full => '16.04',
          },
          :distro => {
            :codename => 'xenial',
          },
        },
      }
    end
    let(:params) do
       { 
         'container_runtime' => 'docker',
         'kubernetes_apt_location' => 'http://apt.kubernetes.io',
         'kubernetes_apt_release' => 'kubernetes-xenial',
         'kubernetes_apt_repos' => 'main',
         'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
         'kubernetes_key_source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
         'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
         'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
         'docker_apt_location' => 'https://apt.dockerproject.org/repo',
         'docker_apt_release' => 'ubuntu-xenial',
         'docker_apt_repos' => 'main',
         'docker_yum_baseurl' => 'https://yum.dockerproject.org/repo/main/centos/7',
         'docker_yum_gpgkey' => 'https://yum.dockerproject.org/gpg',
         'docker_key_id' => '58118E89F3A912897C070ADBF76221572C52609D',
         'docker_key_source' => 'https://apt.dockerproject.org/gpg',
         'create_repos' => true,         
         'manage_docker' => true, 
       }
    end    

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

  context 'with osfamily => RedHat and manage_epel => true and manage_docker => false' do
    let(:facts) do
      {
        :operatingsystem => 'RedHat',
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7.0',
      }
    end
    let(:facts) do
      {
        :kernel           => 'Linux',
        :os               => {
          :family  => 'RedHat',
          :name    => 'RedHat',
          :release => {
            :full => '7.0',
          },
        },
      }
    end

    let(:params) do
      { 
        'container_runtime' => 'docker',
        'kubernetes_apt_location' => 'http://apt.kubernetes.io',
        'kubernetes_apt_release' => 'kubernetes-xenial',
        'kubernetes_apt_repos' => 'main',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://apt.dockerproject.org/repo',
        'docker_apt_release' => 'ubuntu-xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://yum.dockerproject.org/repo/main/centos/7',
        'docker_yum_gpgkey' => 'https://yum.dockerproject.org/gpg',
        'docker_key_id' => '58118E89F3A912897C070ADBF76221572C52609D',
        'docker_key_source' => 'https://apt.dockerproject.org/gpg',
        'create_repos' => true,
        'manage_docker' => false,
       }
   end 

    it { should_not contain_yumrepo('docker') }
    it { should contain_yumrepo('kubernetes') }
  end
end
