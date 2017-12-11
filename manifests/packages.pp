# Class kubernetes packages

class kubernetes::packages (

  $kubernetes_package_version = $kubernetes::kubernetes_package_version,
  $container_runtime = $kubernetes::container_runtime,
  $cni_version = $kubernetes::cni_version,
) {

  $kube_packages = ['kubelet', 'kubectl']

  if $container_runtime == 'docker' {
    case $::osfamily {
      'Debian' : {
        package { 'docker-engine':
        ensure => '1.12.0-0~xenial',
        }
      }

      'RedHat' : {
        package { 'docker-engine':
          ensure => '1.12.6',
        }
      }

    default: { notify {"The OS family ${::os_family} is not supported by this module":} }
    }

    package { 'kubernetes-cni':
      ensure => $cni_version,
    }
  }

  elsif $container_runtime == 'cri_containerd' {
    wget::fetch { 'wget cri-containerd':
      source      => 'https://github.com/kubernetes-incubator/cri-containerd/releases/download/v1.0.0-alpha.1/cri-containerd-1.0.0-alpha.1.tar.gz',
      destination => '/',
      timeout     => 0,
      verbose     => false,
    }

  -> archive { 'cri-containerd-1.0.0-alpha.1.tar.gz':
      ensure          => present,
      path            => '/cri-containerd-1.0.0-alpha.1.tar.gz',
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
