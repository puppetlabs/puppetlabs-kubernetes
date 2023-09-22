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
            full: '22.04'
          },
          distro: {
            codename: 'jammy'
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
        'docker_apt_release' => '',
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
      is_expected.to contain_apt__source('kubernetes').with(
        ensure: 'present',
        location: 'https://pkgs.k8s.io/core:/stable:/v1.28/deb',
        release: '/',
        key: { 'name' => 'kubernetes-apt-keyring.asc', 'source' => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key' },
      )
    }

    it {
      is_expected.to contain_file('/etc/apt/sources.list.d/kubernetes.list')
        .with_content(%r{^deb \[signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc\] https://pkgs.k8s.io/core:/stable:/v1.28/deb /\s$})
    }

    it {
      is_expected.to contain_apt__keyring('kubernetes-apt-keyring.asc')
        .with_source('https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key')
    }

    it { is_expected.to contain_file('/etc/apt/keyrings/kubernetes-apt-keyring.asc') }

    it {
      is_expected.to contain_apt__source('docker').with(
        ensure: 'present',
        location: 'https://download.docker.com/linux/ubuntu',
        repos: 'main',
        release: 'jammy',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/ubuntu/gpg' },
      )
    }
  end

  context 'with Debian, a custom kubernetes_apt_location and no key parameters' do
    let(:facts) do
      {
        osfamily: 'Debian', # needed to run dependent tests from fixtures puppetlabs-apt
        kernel: 'Linux',
        os: {
          family: 'Debian',
          name: 'Debian',
          release: {
            full: '12.0'
          },
          distro: {
            codename: 'bookworm'
          }
        }
      }
    end
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'kubernetes_version' => '1.30.4',
        'kubernetes_apt_location' => 'https://mirror.example.com/kubernetes/deb/',
        'kubernetes_apt_release' => '',
        'kubernetes_apt_repos' => '',
        'kubernetes_key_id' => '',
        'kubernetes_key_source' => '',
        'kubernetes_yum_baseurl' => '',
        'kubernetes_yum_gpgkey' => '',
        'docker_apt_location' => '',
        'docker_apt_release' => '',
        'docker_apt_repos' => '',
        'docker_yum_baseurl' => '',
        'docker_yum_gpgkey' => '',
        'docker_key_id' => '',
        'docker_key_source' => '',
        'containerd_install_method' => 'package',
        'create_repos' => true,
        'manage_docker' => true
      }
    end

    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_apt__source('kubernetes').with(
        location: 'https://mirror.example.com/kubernetes/deb/',
        release: '/',
        key: { 'name' => 'kubernetes-apt-keyring.asc', 'source' => 'https://mirror.example.com/kubernetes/deb/Release.key' },
      )
    }

    it {
      is_expected.to contain_apt__keyring('kubernetes-apt-keyring.asc')
        .with_source('https://mirror.example.com/kubernetes/deb/Release.key')
    }

    it {
      is_expected.to contain_apt__source('docker').with(
        location: 'https://download.docker.com/linux/debian',
        repos: 'stable',
        release: 'bookworm',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/debian/gpg' },
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
            full: '22.04'
          },
          distro: {
            codename: 'jammy'
          }
        }
      }
    end
    let(:params) do
      {
        'container_runtime' => 'docker',
        'kubernetes_version' => '1.32.0',
        'kubernetes_apt_location' => 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/',
        'kubernetes_apt_release' => ' /',
        'kubernetes_apt_repos' => ' ',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/debian',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/rhel/8/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/rhel/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/debian/gpg',
        'containerd_install_method' => 'archive',
        'create_repos' => true,
        'manage_docker' => true
      }
    end

    it {
      is_expected.to contain_apt__source('kubernetes').with(
        ensure: 'present',
        location: 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/',
        repos: ' ',
        release: ' /',
        key: { 'id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB', 'source' => 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key' },
      )
    }

    it {
      is_expected.to contain_apt__source('docker').with(
        ensure: 'present',
        location: 'https://download.docker.com/linux/debian',
        repos: 'main',
        release: 'xenial',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/debian/gpg' },
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
        'kubernetes_version' => '1.32.0',
        'kubernetes_apt_location' => 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/',
        'kubernetes_apt_release' => ' /',
        'kubernetes_apt_repos' => ' ',
        'kubernetes_key_id' => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
        'kubernetes_key_source' => 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key',
        'kubernetes_yum_baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'kubernetes_yum_gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        'docker_apt_location' => 'https://download.docker.com/linux/debian',
        'docker_apt_release' => 'xenial',
        'docker_apt_repos' => 'main',
        'docker_yum_baseurl' => 'https://download.docker.com/linux/rhel/8/x86_64/stable',
        'docker_yum_gpgkey' => 'https://download.docker.com/linux/rhel/gpg',
        'docker_key_id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        'docker_key_source' => 'https://download.docker.com/linux/debian/gpg',
        'containerd_install_method' => 'package',
        'create_repos' => true,
        'manage_docker' => true
      }
    end

    it {
      is_expected.to contain_apt__source('kubernetes').with(
        ensure: 'present',
        location: 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/',
        repos: ' ',
        release: ' /',
        key: { 'name' => 'kubernetes-apt-keyring.gpg', 'source' => 'https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key' },
      )
    }

    it {
      is_expected.to contain_apt__source('docker').with(
        ensure: 'present',
        location: 'https://download.docker.com/linux/debian',
        repos: 'main',
        release: 'xenial',
        key: { 'id' => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88', 'source' => 'https://download.docker.com/linux/debian/gpg' },
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
      is_expected.to contain_yumrepo('kubernetes').with(
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
      is_expected.to contain_yumrepo('kubernetes').with(
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
        'docker_apt_release' => 'jammy',
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
      is_expected.to contain_yumrepo('kubernetes').with(
        'enabled' => '1',
        'baseurl' => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        'gpgkey' => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
      )
    }
  end
end
