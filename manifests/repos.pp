## kubernetes repos

# @param container_runtime
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker". Defaults to cri_containerd
# @param kubernetes_version
#   The kubernetes version used to determine the minor release of the pkgs.k8s.io repository.
# @param kubernetes_apt_location
#   The APT repo URL for the Kubernetes packages. Defaults to https://pkgs.k8s.io/core:/stable:/v<major.minor>/deb
# @param kubernetes_apt_release
#   The release name for the APT repo for the Kubernetes packages. Defaults to '/' (flat repository)
# @param kubernetes_apt_repos
#   The repos to install from the Kubernetes APT url. Defaults to main. Ignored when the release ends with '/'
# @param kubernetes_key_id
#   The gpg key id for the Kubernetes APT repo. When set, the key is installed with the legacy apt-key mechanism.
#   Defaults to undef, the signing key is then installed with apt::keyring and referenced via signed-by.
# @param kubernetes_key_source
#   The URL for the APT repo gpg key. Defaults to <kubernetes_apt_location>/Release.key
# @param kubernetes_yum_baseurl
#   The YUM repo URL for the Kubernetes packages. Defaults to https://pkgs.k8s.io/core:/stable:/v<major.minor>/rpm/
# @param kubernetes_yum_gpgkey
#   The URL for the Kubernetes yum repo gpg key. Defaults to <kubernetes_yum_baseurl>/repodata/repomd.xml.key
# @param docker_apt_location
#   The APT repo URL for the Docker packages. Defaults to https://download.docker.com/linux/<os name>
# @param docker_apt_release
#   The release name for the APT repo for the Docker packages. Defaults to $facts.os.distro.codename
# @param docker_apt_repos
#   The repos to install from the Docker APT url. Defaults to stable
# @param docker_yum_baseurl
#   The YUM repo URL for the Docker packages. Defaults to https://download.docker.com/linux/centos/7/x86_64/stable
# @param docker_yum_gpgkey
#   The URL for the Docker yum repo gpg key. Defaults to https://download.docker.com/linux/centos/gpg
# @param docker_key_id
#   The gpg key for the Docker APT repo. Defaults to '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
# @param docker_key_source
#   The URL for the Docker APT repo gpg key. Defaults to https://download.docker.com/linux/<os name>/gpg
# @param containerd_install_method
#   Whether to install containerd via archive or package. Defaults to archive
# @param manage_docker
#   Whether or not to install Docker repositories and packages via this module. Defaults to true.
# @param create_repos
#   A flag to install the upstream Kubernetes and Docker repos. Defaults to true
#
class kubernetes::repos (
  String $container_runtime                   = $kubernetes::container_runtime,
  String[1] $kubernetes_version               = $kubernetes::kubernetes_version,
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

) inherits kubernetes {
  if $create_repos {
    # pkgs.k8s.io publishes one repository per minor release, e.g. https://pkgs.k8s.io/core:/stable:/v1.28/
    $parts = split($kubernetes_version, '[.]')
    $minor_version = "${parts[0]}.${parts[1]}"
    $k8s_repo_base = "https://pkgs.k8s.io/core:/stable:/v${minor_version}"

    $manage_docker_repo = ($container_runtime == 'docker' and $manage_docker == true) or
    ($container_runtime == 'cri_containerd' and $containerd_install_method == 'package')

    case $facts['os']['family'] {
      'Debian': {
        $_apt_location = pick($kubernetes_apt_location, "${k8s_repo_base}/deb")
        $_key_source   = pick($kubernetes_key_source, "${regsubst($_apt_location, '/$', '')}/Release.key")

        if $kubernetes_key_id =~ String[1] {
          # Legacy apt-key based key handling, only used when a key id is explicitly given
          $_key = { 'id' => $kubernetes_key_id, 'source' => $_key_source }
        } else {
          # pkgs.k8s.io publishes an ASCII armored signing key. apt reads armored keyrings
          # as long as the file has the .asc extension, so it can be installed as is via
          # apt::keyring and referenced from the source entry via signed-by.
          $_key = { 'name' => 'kubernetes-apt-keyring.asc', 'source' => $_key_source }
        }

        apt::source { 'kubernetes':
          location => $_apt_location,
          # pkgs.k8s.io is a flat repository: the release is '/' and no components are used
          release  => pick($kubernetes_apt_release, '/'),
          repos    => pick($kubernetes_apt_repos, 'main'),
          key      => $_key,
        }

        if $manage_docker_repo {
          $_docker_apt_location = pick($docker_apt_location, "https://download.docker.com/linux/${downcase($facts['os']['name'])}")
          apt::source { 'docker':
            location => $_docker_apt_location,
            repos    => pick($docker_apt_repos, 'stable'),
            release  => pick($docker_apt_release, fact('os.distro.codename')),
            key      => {
              'id'     => pick($docker_key_id, '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'),
              'source' => pick($docker_key_source, "${regsubst($_docker_apt_location, '/$', '')}/gpg"),
            },
          }
        }
      }
      'RedHat': {
        if $manage_docker_repo {
          yumrepo { 'docker':
            descr    => 'docker',
            baseurl  => pick($docker_yum_baseurl, 'https://download.docker.com/linux/centos/7/x86_64/stable'),
            gpgkey   => pick($docker_yum_gpgkey, 'https://download.docker.com/linux/centos/gpg'),
            gpgcheck => true,
          }
        }

        $_yum_baseurl = pick($kubernetes_yum_baseurl, "${k8s_repo_base}/rpm/")
        yumrepo { 'kubernetes':
          descr    => 'Kubernetes',
          baseurl  => $_yum_baseurl,
          gpgkey   => pick($kubernetes_yum_gpgkey, "${regsubst($_yum_baseurl, '/$', '')}/repodata/repomd.xml.key"),
          enabled  => 1,
          gpgcheck => 1,
        }
      }

      default: { notify { "The OS family ${facts['os']['family']} is not supported by this module": } }
    }
  }
}
