# frozen_string_literal: true

require 'spec_helper'
describe 'kubernetes::repos', type: :class do
  context 'with Debian and default params' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppetlabs-apt
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_version' => '1.28.1',
        'kubernetes_apt_location' => '',
        'kubernetes_apt_release' => '',
        'kubernetes_apt_repos' => '',
        'kubernetes_key_id' => '',
        'kubernetes_key_source' => '',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/ubuntu',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/centos/7/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/centos/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/ubuntu/gpg',
        'containerd_install_method' => 'archive',
        'create_repos' => true,
        'manage_docker' => true
      }
    end

    it {
      expect(subject).to contain_apt__source('kubernetes').with(
        ensure: 'present',
        location: 'https://pkgs.k8s.io/core:/stable:/v1.28/deb',
        release: '/',
        keyring: '/usr/share/keyrings/kubernetes-apt-keyring.gpg',
      )
    }

    it {
      expect(subject).to contain_file('/etc/apt/sources.list.d/kubernetes.list')
        .with_content(%r{^deb \[signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg\] https://pkgs.k8s.io/core:/stable:/v1.28/deb /\s$})
    }

    it {
      expect(subject).to contain_apt__source('docker').with(
        ensure: 'present',
        location: 'https://download.docker.com/linux/ubuntu',
        repos: 'main',
        release: 'xenial',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/ubuntu/gpg' },
      )
    }
  end

  context 'with osfamily => Ubuntu and manage_docker => true' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppetlabs-apt
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_version' => '1.28.1',
        'kubernetes_apt_location' => 'http://apt.kubernetes.io',
        'kubernetes_apt_release' => 'kubernetes-xenial',
        'kubernetes_apt_repos' => 'main',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/ubuntu',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/centos/7/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/centos/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/ubuntu/gpg',
        'containerd_install_method' => 'archive',
        'create_repos' => true,
        'manage_docker' => true
      }
    end

    it {
      expect(subject).to contain_apt__source('kubernetes').with(
        ensure: 'present',
        location: 'http://apt.kubernetes.io',
        repos: 'main',
        release: 'kubernetes-xenial',
        key: { 'id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB', 'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg' },
      )
    }

    it {
      expect(subject).to contain_apt__source('docker').with(
        ensure: 'present',
        location: 'https://download.docker.com/linux/ubuntu',
        repos: 'main',
        release: 'xenial',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/ubuntu/gpg' },
      )
    }
  end

  context 'with osfamily => Ubuntu and container_runtime => cri_containerd and containerd_install_method => package' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppetlabs-apt
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            full: '16.04'
          },
          distro: {
            codename: 'xenial'
          }
        }
      }
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_version' => '1.28.1',
        'kubernetes_apt_location' => 'http://apt.kubernetes.io',
        'kubernetes_apt_release' => 'kubernetes-xenial',
        'kubernetes_apt_repos' => 'main',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/ubuntu',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/centos/7/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/centos/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/ubuntu/gpg',
        'containerd_install_method' => 'package',
        'create_repos' => true,
        'manage_docker' => true
      }
    end

    it {
      expect(subject).to contain_apt__source('kubernetes').with(
        ensure: 'present',
        location: 'http://apt.kubernetes.io',
        repos: 'main',
        release: 'kubernetes-xenial',
        key: { 'id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB', 'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg' },
      )
    }

    it {
      expect(subject).to contain_apt__source('docker').with(
        ensure: 'present',
        location: 'https://download.docker.com/linux/ubuntu',
        repos: 'main',
        release: 'xenial',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/ubuntu/gpg' },
      )
    }
  end

  context 'with RedHat and default params' do
    let(:facts) do
      {
        operatingsystem: 'RedHat',
        osfamily: 'RedHat',
        operatingsystemrelease: '7.0',
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.0'
          }
        }
      }
    end

    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_version' => '1.28.1',
        'kubernetes_apt_location' => '',
        'kubernetes_apt_release' => '',
        'kubernetes_apt_repos' => '',
        'kubernetes_key_id' => '',
        'kubernetes_key_source' => '',
        'kubernetes_yum_baseurl' => '',
        'kubernetes_yum_gpgkey' => '',
        'docker_apt_location' => 'https://download.docker.com/linux/ubuntu',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/centos/7/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/centos/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/ubuntu/gpg',
        'containerd_install_method' => 'archive',
        'create_repos' => true,
        'manage_docker' => false
      }
    end

    it { is_expected.not_to contain_yumrepo('docker') }

    it {
      expect(subject).to contain_yumrepo('kubernetes').with(
        'enabled' => '1',
        'baseurl' => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/',
        'gpgkey' => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key',
      )
    }
  end

  context 'with osfamily => RedHat and manage_epel => true and manage_docker => false' do
    let(:facts) do
      {
        operatingsystem: 'RedHat',
        osfamily: 'RedHat',
        operatingsystemrelease: '7.0',
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.0'
          }
        }
      }
    end

    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_version' => '1.28.1',
        'kubernetes_apt_location' => 'http://apt.kubernetes.io',
        'kubernetes_apt_release' => 'kubernetes-xenial',
        'kubernetes_apt_repos' => 'main',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/ubuntu',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/centos/7/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/centos/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/ubuntu/gpg',
        'containerd_install_method' => 'archive',
        'create_repos' => true,
        'manage_docker' => false
      }
    end

    it { is_expected.not_to contain_yumrepo('docker') }

    it {
      expect(subject).to contain_yumrepo('kubernetes').with(
        'enabled' => '1',
        'baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
      )
    }
  end

  context 'with osfamily => RedHat and container_runtime => cri_containerd and containerd_install_method => package' do
    let(:facts) do
      {
        operatingsystem: 'RedHat',
        osfamily: 'RedHat',
        operatingsystemrelease: '7.0',
        kernel: 'Linux',
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '7.0'
          }
        }
      }
    end

    let(:params) do
      {
        'kubernetes_version' => '1.28.1',
        'container_runtime' => 'cri_containerd',
        'kubernetes_apt_location' => 'http://apt.kubernetes.io',
        'kubernetes_apt_release' => 'kubernetes-xenial',
        'kubernetes_apt_repos' => 'main',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/ubuntu',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/centos/7/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/centos/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/ubuntu/gpg',
        'containerd_install_method' => 'package',
        'create_repos' => true,
        'manage_docker' => false
      }
    end

    it { is_expected.to contain_yumrepo('docker') }

    it {
      expect(subject).to contain_yumrepo('kubernetes').with(
        'enabled' => '1',
        'baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
      )
    }
  end
end
