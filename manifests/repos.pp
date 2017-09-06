## Kubernetes repos 

class kubernetes::repos (
  $manage_epel = $kubernetes::manage_epel,
){

  $repo = downcase($::operatingsystem)

  case $::osfamily  {
    'Debian': {
      apt::source { 'kubernetes':
        location => 'http://apt.kubernetes.io',
        repos    => 'main',
        release  => 'kubernetes-xenial',
        key      => {
          'id'     => 'D0BC747FD8CAF7117500D6FA3746C208A7317B0F',
          'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
          },
        }

        apt::source { 'docker':
          location => 'https://apt.dockerproject.org/repo',
          repos    => 'main',
          release  => 'ubuntu-xenial',
          key      => {
            'id'     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
            'source' => 'https://download.docker.com/linux/ubuntu/gpg',
        },
      }
    }
    'RedHat': {
      if $manage_epel {
        include epel
      }

      yumrepo { 'docker':
        descr    => 'docker',
        baseurl  => "https://yum.dockerproject.org/repo/main/${repo}/7",
        gpgkey   => 'https://yum.dockerproject.org/gpg',
        gpgcheck => true,
      }

      yumrepo { 'kubernetes':
        descr    => 'Kubernetes',
        baseurl  => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
        gpgkey   => 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
        gpgcheck => true,
      }
    }

  default: { notify {"The OS family ${::os_family} is not supported by this module":} }

  }
}
