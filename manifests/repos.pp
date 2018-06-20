## kubernetes repos

class kubernetes::repos (
  String $container_runtime = $kubernetes::container_runtime,
){

  case $::osfamily  {
    'Debian': {

      apt::source { 'kubernetes':
        location => 'http://apt.kubernetes.io',
        repos    => 'main',
        release  => 'kubernetes-xenial',
        key      => {
          'id'     => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
          'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
        },
      }

      if $container_runtime == 'docker' {
        case $::operatingsystem {
          'Ubuntu': {
            apt::source { 'docker':
              location => 'https://apt.dockerproject.org/repo',
              repos    => 'main',
              release  => 'ubuntu-xenial',
              key      => {
                'id'     => '58118E89F3A912897C070ADBF76221572C52609D',
                'source' => 'https://apt.dockerproject.org/gpg',
              },
            }
          }
          'Debian': {
            apt::source { 'docker':
              location => 'https://apt.dockerproject.org/repo',
              repos    => 'main',
              release  => 'debian-stretch',
              key      => {
                'id'     => '58118E89F3A912897C070ADBF76221572C52609D',
                'source' => 'https://apt.dockerproject.org/gpg',
              },
            }
          }
          default: { notify {"The ${::operatingsystem} variant of Debian is not supported by this module":} }
        }
      }
    }
    'RedHat': {
      if $container_runtime == 'docker' {
        yumrepo { 'docker':
          descr    => 'docker',
          baseurl  => 'https://yum.dockerproject.org/repo/main/centos/7',
          gpgkey   => 'https://yum.dockerproject.org/gpg',
          gpgcheck => true,
        }
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
