# Class kubernetes packages

class kubernetes::packages (

  Optional[String] $kubernetes_package_version = $kubernetes::kubernetes_package_version,
  String $container_runtime                    = $kubernetes::container_runtime,
  String $docker_package_name                  = $kubernetes::docker_package_name,
  String $docker_package_version               = $kubernetes::docker_package_version,
  Boolean $package_pin                         = $kubernetes::package_pin,
  String $cni_package_name                     = $kubernetes::cni_package_name,
  String $cni_version                          = $kubernetes::cni_version,

) {

  $kube_packages = ['kubelet', 'kubectl']

  case $kubernetes_package_version {
    /1[.]9[.]\d/: {
      $cri_source = 'https://github.com/containerd/cri-containerd/releases/download/v1.0.0-beta.1/cri-containerd-1.0.0-beta.1.linux-amd64.tar.gz'
      $cri_archive = 'cri-containerd-1.0.0-beta.1.linux-amd64.tar.gz'
    }
    default: {
      $cri_source = 'https://github.com/containerd/cri-containerd/releases/download/v1.0.0-alpha.1/cri-containerd-1.0.0-alpha.1.tar.gz'
      $cri_archive = 'cri-containerd-1.0.0-alpha.1.tar.gz'
    }
  }

  if $container_runtime == 'docker' {
    if $package_pin {
      if $::osfamily == 'Debian' {
        include apt

        apt::pin { 'docker-engine':
          packages => $docker_package_name,
          version  => $docker_package_version,
          priority => '550',
        }

        apt::pin { 'kube':
          packages => $kube_packages,
          version  => $kubernetes_package_version,
          priority => '550',
        }

        apt::pin { 'kubernetes-cni':
          packages => $cni_package_name,
          version  => $cni_version,
          priority => '550',
        }
      }
    }

    package { $docker_package_name:
      ensure => $docker_package_version,
    }

    package { $cni_package_name:
      ensure => $cni_version,
    }
  }

  elsif $container_runtime == 'cri_containerd' {
    wget::fetch { 'wget cri-containerd':
      source      => $cri_source,
      destination => '/',
      timeout     => 0,
      verbose     => false,
    }

  -> archive { $cri_archive:
      ensure          => present,
      path            => "/${cri_archive}",
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1',
      extract_path    => '/',
      cleanup         => true,
      creates         => '/usr/local/bin/cri-containerd'
    }
  }

  package { $kube_packages:
    ensure => $kubernetes_package_version,
  }
}
