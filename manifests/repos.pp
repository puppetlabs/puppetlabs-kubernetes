## kubernetes repos

# @param container_runtime
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker". Defaults to cri_containerd
# @param kubernetes_version
#   The kubernetes version used to determine major release version.
# @param kubernetes_apt_location
#   The APT repo URL for the Kubernetes packages. Defaults to https://apt.kubernetes.io
# @param kubernetes_apt_release
#   The release name for the APT repo for the Kubernetes packages. Defaults to 'kubernetes-${facts.os.distro.codename}'
# @param kubernetes_apt_repos
#   The repos to install from the Kubernetes APT url. Defaults to main
# @param kubernetes_key_id
#   The gpg key for the Kubernetes APT repo. Defaults to '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB'
# @param kubernetes_key_source
#   The URL for the APT repo gpg key. Defaults to https://packages.cloud.google.com/apt/doc/apt-key.gpg
# @param kubernetes_yum_baseurl
#   The YUM repo URL for the Kubernetes packages. Defaults to https://download.docker.com/linux/centos/
# @param kubernetes_yum_gpgkey
#   The URL for the Kubernetes yum repo gpg key. Defaults to https://download.docker.com/linux/centos/gpg
# @param docker_apt_location
#   The APT repo URL for the Docker packages. Defaults to https://apt.dockerproject.org/repo
# @param docker_apt_release
#   The release name for the APT repo for the Docker packages. Defaults to $facts.os.distro.codename
# @param docker_apt_repos
#   The repos to install from the Docker APT url. Defaults to main
# @param docker_yum_baseurl
#   The YUM repo URL for the Docker packages. Defaults to https://download.docker.com/linux/centos/7/x86_64/stable
# @param docker_yum_gpgkey
#   The URL for the Docker yum repo gpg key. Defaults to https://download.docker.com/linux/centos/gpg
# @param docker_key_id
#   The gpg key for the Docker APT repo. Defaults to '58118E89F3A912897C070ADBF76221572C52609D'
# @param docker_key_source
#   The URL for the Docker APT repo gpg key. Defaults to https://apt.dockerproject.org/gpg
# @param containerd_install_method
#   Whether to install containerd via archive or package. Defaults to archive
# @param manage_docker
#   Whether or not to install Docker repositories and packages via this module. Defaults to true.
# @param create_repos
#   A flag to install the upstream Kubernetes and Docker repos. Defaults to true
#
class kubernetes::repos (
  String $container_runtime                   = $kubernetes::container_runtime,
  Optional[String] $kubernetes_version        = $kubernetes::kubernetes_version,
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
    $parts = split($kubernetes_version, '[.]')
    $minor_version = "${parts[0]}.${parts[1]}"
    $_repos = $kubernetes_apt_repos ? {
      undef   => '',
      default => $kubernetes_apt_repos
    }
    case $facts['os']['family'] {
      'Debian': {
        $codename = fact('os.distro.codename')
        apt::source { 'kubernetes':
          location => pick($kubernetes_apt_location,"https://pkgs.k8s.io/core:/stable:/v${minor_version}/deb"),
          release  => pick($kubernetes_apt_release, '/'),
          repos    => $_repos,
          key      => {
            'id'     => pick($kubernetes_key_id,'DE15B14486CD377B9E876E1A234654DA9A296436'),
            'source' => pick($kubernetes_key_source,"https://pkgs.k8s.io/core:/stable:/v${minor_version}/deb/Release.key"),
          },
        }

        if ($container_runtime == 'docker' and $manage_docker == true) or
        ($container_runtime == 'cri_containerd' and $containerd_install_method == 'package') {
          apt::source { 'docker':
            location => pick($docker_apt_location,'https://download.docker.com/linux/ubuntu/'),
            repos    => pick($docker_apt_repos,'stable'),
            release  => pick($docker_apt_release,$codename),
            key      => {
              'id'     => pick($docker_key_id,'9DC858229FC7DD38854AE2D88D81803C0EBFCD88'),
              'source' => pick($docker_key_source,'https://download.docker.com/linux/ubuntu/gpg'),
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
          baseurl  => pick($kubernetes_yum_baseurl,"https://pkgs.k8s.io/core:/stable:/v${minor_version}/rpm/"),
          gpgkey   => pick($kubernetes_yum_gpgkey,"https://pkgs.k8s.io/core:/stable:/v${minor_version}/rpm/repodata/repomd.xml.key"),
          enabled  => 1,
          gpgcheck => 1,
        }
      }

      default: { notify { "The OS family ${facts['os']['family']} is not supported by this module": } }
    }
  }
}
