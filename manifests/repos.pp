## kubernetes repos

class kubernetes::repos (
  String $container_runtime                   = $kubernetes::container_runtime,
  Optional[String] $kubernetes_apt_location   = $kubernetes::kubernetes_apt_location,
  Optional[String] $kubernetes_apt_release    = $kubernetes::kubernetes_apt_release,
  Optional[String] $kubernetes_apt_repos      = $kubernetes::kubernetes_apt_repos,
  Optional[String] $kubernetes_key_id         = $kubernetes::kubernetes_key_id,
  Optional[String] $kubernetes_key_source     = $kubernetes::kubernetes_key_source,
  Optional[String] $kubernetes_yum_baseurl    = $kubernetes::kubernetes_yum_baseurl,
  Optional[String] $kubernetes_yum_gpgkey     = $kubernetes::kubernetes_yum_gpgkey,
  Optional[String] $docker_apt_location       = $kubernetes::docker_apt_location,
  Optional[String] $docker_apt_release        = $kubernetes::docker_apt_release,
  Optional[String] $docker_apt_repos          = $kubernetes::docker_apt_repos,
  Optional[String] $docker_yum_baseurl        = $kubernetes::docker_yum_baseurl,
  Optional[String] $docker_yum_gpgkey         = $kubernetes::docker_yum_gpgkey,
  Optional[String] $docker_key_id             = $kubernetes::docker_key_id,
  Optional[String] $docker_key_source         = $kubernetes::docker_key_source,
  Optional[String] $containerd_install_method = $kubernetes::containerd_install_method,
  Boolean $manage_docker                      = $kubernetes::manage_docker,
  Boolean $create_repos                       = $kubernetes::create_repos,

) {
  if $create_repos {
    case $facts['os']['family'] {
      'Debian': {
        $codename = fact('os.distro.codename')
        apt::source { 'kubernetes':
          location => pick($kubernetes_apt_location,'https://apt.kubernetes.io'),
          repos    => pick($kubernetes_apt_repos,'main'),
          release  => pick($kubernetes_apt_release,'kubernetes-xenial'),
          key      => {
            'id'     => pick($kubernetes_key_id,'7F92E05B31093BEF5A3C2D38FEEA9169307EA071'),
            'source' => pick($kubernetes_key_source,'https://packages.cloud.google.com/apt/doc/apt-key.gpg'),
          },
        }

        if ($container_runtime == 'docker' and $manage_docker == true) or
            ($container_runtime == 'cri_containerd' and $containerd_install_method == 'package') {
          apt::source { 'docker':
            location => pick($docker_apt_location,'https://apt.dockerproject.org/repo'),
            repos    => pick($docker_apt_repos,'main'),
            release  => pick($docker_apt_release,"ubuntu-${codename}"),
            key      => {
              'id'     => pick($docker_key_id,'58118E89F3A912897C070ADBF76221572C52609D'),
              'source' => pick($docker_key_source,'https://apt.dockerproject.org/gpg'),
            },
          }
        }
      }
      'RedHat': {
        if ($container_runtime == 'docker' and $manage_docker == true) or
            ($container_runtime == 'cri_containerd' and $containerd_install_method == 'package') {
          yumrepo { 'docker':
            descr    => 'docker',
            baseurl  => pick($docker_yum_baseurl,'https://download.docker.com/linux/centos/7/x86_64/stable'),
            gpgkey   => pick($docker_yum_gpgkey,'https://download.docker.com/linux/centos/gpg'),
            gpgcheck => true,
          }
        }

        yumrepo { 'kubernetes':
          descr    => 'Kubernetes',
          baseurl  => pick($kubernetes_yum_baseurl,'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64'),
          gpgkey   => pick($kubernetes_yum_gpgkey,'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg'),
          gpgcheck => true,
        }
      }

      default: { notify { "The OS family ${facts['os']['family']} is not supported by this module": } }
    }
  }
}
