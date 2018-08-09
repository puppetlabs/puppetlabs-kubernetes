## kubernetes repos

class kubernetes::repos (
  String $container_runtime                 = $kubernetes::container_runtime,
  Optional[String] $kubernetes_apt_location = $kubernetes::kubernetes_apt_location,
  Optional[String] $kubernetes_apt_release  = $kubernetes::kubernetes_apt_release,
  Optional[String] $kubernetes_apt_repos    = $kubernetes::kubernetes_apt_repos,
  Optional[String] $kubernetes_key_id       = $kubernetes::kubernetes_key_id,
  Optional[String] $kubernetes_key_source   = $kubernetes::kubernetes_key_source,
  Optional[String] $kubernetes_yum_baseurl  = $kubernetes::kubernetes_yum_baseurl,
  Optional[String] $kubernetes_yum_gpgkey   = $kubernetes::kubernetes_yum_gpgkey,
  Optional[String] $docker_apt_location     = $kubernetes::docker_apt_location,
  Optional[String] $docker_apt_release      = $kubernetes::docker_apt_release,
  Optional[String] $docker_apt_repos        = $kubernetes::docker_apt_repos,
  Optional[String] $docker_yum_baseurl      = $kubernetes::docker_yum_baseurl,
  Optional[String] $docker_yum_gpgkey       = $kubernetes::docker_yum_gpgkey,
  Optional[String] $docker_key_id           = $kubernetes::docker_key_id,
  Optional[String] $docker_key_source       = $kubernetes::docker_key_source,
  Boolean $manage_docker                    = $kubernetes::manage_docker,
  Boolean $create_repos                     = $kubernetes::create_repos,


){
  if $create_repos {
    case $::osfamily  {
      'Debian': {
        apt::source { 'kubernetes':
          location => $kubernetes_apt_location,
          repos    => $kubernetes_apt_repos,
          release  => $kubernetes_apt_release,
          key      => {
            'id'     => $kubernetes_key_id,
            'source' => $kubernetes_key_source,
            },
          }

          if $container_runtime == 'docker' and $manage_docker == true {
            apt::source { 'docker':
              location => $docker_apt_location,
              repos    => $docker_apt_repos,
              release  => $docker_apt_release,
              key      => {
                'id'     => $docker_key_id,
                'source' => $docker_key_source,
            },
          }
        }
      }
      'RedHat': {
        if $container_runtime == 'docker' and $manage_docker == true {
          yumrepo { 'docker':
            descr    => 'docker',
            baseurl  => $docker_yum_baseurl,
            gpgkey   => $docker_yum_gpgkey,
            gpgcheck => true,
          }
        }

        yumrepo { 'kubernetes':
          descr    => 'Kubernetes',
          baseurl  => $kubernetes_yum_baseurl,
          gpgkey   => $kubernetes_yum_gpgkey,
          gpgcheck => true,
        }
      }

    default: { notify {"The OS family ${::os_family} is not supported by this module":} }

    }
  }
}
