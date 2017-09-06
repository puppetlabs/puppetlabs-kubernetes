# Class kubernetes packages

class kubernetes::packages (

  $kubernetes_package_version = $kubernetes::kubernetes_package_version,
  $cni_version = $kubernetes::cni_version,
) {

  $kube_packages = ['kubelet', 'kubectl']

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

  package { $kube_packages:
    ensure => $kubernetes_package_version,
    }

  package { 'kubernetes-cni':
    ensure => $cni_version,
    }
}
