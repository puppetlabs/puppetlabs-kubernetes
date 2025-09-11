# Class kubernetes packages

# @param kubernetes_package_version
#   The version of the packages the Kubernetes os packages to install
#   ie kubectl and kubelet. Defaults to 1.10.2
# @param container_runtime
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker". Defaults to cri_containerd
# @param containerd_sandbox_image
#   The configuration for the image pause container. Defaults k8s.gcr.io/pause:3.2
# @param manage_docker
#   Whether or not to install Docker repositories and packages via this module.
#   Defaults to true.
# @param manage_etcd
#   When set to true, etcd will be downloaded from the specified source URL.
#   Defaults to true.
# @param docker_version
#   This is the version of the docker runtime that you want to install.
#   Defaults to 17.03.0.ce-1.el7.centos on RedHat
#   Defaults to 5:20.10.11~3-0~ubuntu-(distro codename) on Ubuntu
# @param docker_package_name
#   The docker package name to download from an upstream repo. Defaults to docker-engine
# @param docker_storage_driver
#   Storage Driver to be added to `/etc/docker/daemon.json`. Defaults to overlay2
# @param docker_cgroup_driver
#   The cgroup driver to be used. Defaults to 'systemd'
# @param docker_storage_opts
#   Storage options to be added to `/etc/docker/daemon.json`. Defaults to undef
# @param docker_extra_daemon_config
#   Extra configuration to be added to `/etc/docker/daemon.json`. Defaults to undef
# @param docker_log_max_file
#   The maximum number of log files that can be present.
#   Defaults to 1. See https://docs.docker.com/config/containers/logging/json-file/
# @param docker_log_max_size
#   The maximum size of the log before it is rolled.
#   A positive integer plus a modifier representing the unit of measure (k, m, or g).
#   Defaults to 100m. See https://docs.docker.com/config/containers/logging/json-file/
# @param controller
#   This is a bool that sets the node as a Kubernetes controller. Defaults to false
# @param containerd_version
#   This is the version of the containerd runtime the module will install. Defaults to 1.1.0
# @param containerd_install_method
#   Whether to install containerd via archive or package. Defaults to archive
# @param containerd_package_name
#   containerd package name. Defaults to containerd.io
# @param containerd_archive
#   The name of the containerd archive
#   Defaults to containerd-${containerd_version}.linux-amd64.tar.gz
# @param containerd_archive_checksum
#   A checksum (sha-256) of the archive. If the checksum does not match, a reinstall will be executed and the related service will be
#   restarted. If no checksum is defined, the puppet module checks for the extracted files of the archive and downloads and extracts
#   the files if they do not exist.
# @param containerd_source
#   The URL to download the containerd archive
#   Defaults to https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}
# @param containerd_config_template
#   The template to use for containerd configuration
#   This value is ignored if containerd_config_source is defined. Default to 'kubernetes/containerd/config.toml.epp'
# @param containerd_config_source
#   The source of the containerd configuration
#   This value overrides containerd_config_template. Default to undef
# @param containerd_plugins_registry
#   The configuration for the image registries used by containerd when containerd_install_method is package.
#   See https://github.com/containerd/containerd/blob/master/docs/cri/registry.md. Defaults to `undef`
# @param containerd_default_runtime_name
#   The default runtime to use with containerd. Defaults to runc
# @param etcd_archive
#   The name of the etcd archive. Defaults to etcd-v${etcd_version}-linux-amd64.tar.gz
# @param etcd_archive_checksum
#   A checksum (sha-256) of the archive. If the checksum does not match, a reinstall will be executed and the related service will be
#   restarted. If no checksum is defined, the puppet module checks for the extracted files of the archive and downloads and extracts
#   the files if they do not exist.
# @param etcd_version
#   The version of etcd that you would like to use. Defaults to 3.2.18
# @param etcd_source
#   The URL to download the etcd archive. Defaults to https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}
# @param etcd_package_name
#   The system package name for installing etcd. Defaults to etcd-server
# @param etcd_install_method
#   The method on how to install etcd. Can be either wget (using etcd_source) or package (using $etcd_package_name). Defaults to wget
# @param runc_source
#   The URL to download runc. Defaults to https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64
# @param runc_source_checksum
#   Defaults to undef
# @param disable_swap
#   A flag to turn off the swap setting. This is required for kubeadm. Defaults to true
# @param manage_kernel_modules
#   A flag to manage required Kernel modules. Defaults to true
# @param manage_sysctl_settings
#   A flag to manage required sysctl settings. Defaults to true
# @param create_repos
#   A flag to install the upstream Kubernetes and Docker repos. Defaults to true
# @param pin_packages
#   Enable pinning of the docker and kubernetes packages to prevent accidential updates.
#   This is currently only implemented for debian based distributions. Defaults to false
# @param package_pin_priority
#   Defaults to 32767
# @param archive_checksum_type
#   Defaults to 'sha256'
# @param archive_cleanup
#   Whether downloaded archives should be deleted after extracting. Cleaning files will save some space,
#   but might lead to frequent corrective changes (service restarts)
#   Default: false
# @param tmp_directory
#   Directory to use when downloading archives for install.
#   Default to /var/tmp/puppetlabs-kubernetes
# @param http_proxy
#   Configure the HTTP_PROXY environment variable. Defaults to undef
# @param https_proxy
#   Configure the HTTPS_PROXY environment variable. Defaults to undef
# @param no_proxy
#   Configure the NO_PROXY environment variable. Defaults to undef
# @param container_runtime_use_proxy
#   Configure whether the container runtime should be configured to use a proxy.
#   If set to true, the container runtime will use the http_proxy, https_proxy and
#   no_proxy values. Defaults to false
# @param containerd_socket
#   The path to containerd GRPC socket. Defaults to /run/containerd/containerd.sock
#
class kubernetes::packages (
  String $kubernetes_package_version                    = $kubernetes::kubernetes_package_version,
  String $container_runtime                             = $kubernetes::container_runtime,
  String $containerd_sandbox_image                      = $kubernetes::containerd_sandbox_image,
  Boolean $manage_docker                                = $kubernetes::manage_docker,
  Boolean $manage_etcd                                  = $kubernetes::manage_etcd,
  Optional[String] $docker_version                      = $kubernetes::docker_version,
  Optional[String] $docker_package_name                 = $kubernetes::docker_package_name,
  Optional[String] $docker_storage_driver               = $kubernetes::docker_storage_driver,
  Optional[String] $docker_cgroup_driver                = $kubernetes::cgroup_driver,
  Optional[Array] $docker_storage_opts                  = $kubernetes::docker_storage_opts,
  Optional[String] $docker_extra_daemon_config          = $kubernetes::docker_extra_daemon_config,
  String $docker_log_max_file                           = $kubernetes::docker_log_max_file,
  String $docker_log_max_size                           = $kubernetes::docker_log_max_size,
  Boolean $controller                                   = $kubernetes::controller,
  Optional[String] $containerd_version                  = $kubernetes::containerd_version,
  Enum['archive','package'] $containerd_install_method  = $kubernetes::containerd_install_method,
  String $containerd_package_name                       = $kubernetes::containerd_package_name,
  Optional[String] $containerd_archive                  = $kubernetes::containerd_archive,
  Optional[String] $containerd_archive_checksum         = $kubernetes::containerd_archive_checksum,
  Optional[String] $containerd_source                   = $kubernetes::containerd_source,
  String $containerd_config_template                    = $kubernetes::containerd_config_template,
  Optional[String] $containerd_config_source            = $kubernetes::containerd_config_source,
  Optional[Hash] $containerd_plugins_registry           = $kubernetes::containerd_plugins_registry,
  Enum['runc','nvidia']
  $containerd_default_runtime_name                      = $kubernetes::containerd_default_runtime_name,
  String $etcd_archive                                  = $kubernetes::etcd_archive,
  Optional[String] $etcd_archive_checksum               = $kubernetes::etcd_archive_checksum,
  String $etcd_version                                  = $kubernetes::etcd_version,
  String $etcd_source                                   = $kubernetes::etcd_source,
  String $etcd_package_name                             = $kubernetes::etcd_package_name,
  String $etcd_install_method                           = $kubernetes::etcd_install_method,
  Optional[String] $runc_source                         = $kubernetes::runc_source,
  Optional[String] $runc_source_checksum                = $kubernetes::runc_source_checksum,
  Boolean $disable_swap                                 = $kubernetes::disable_swap,
  Boolean $manage_kernel_modules                        = $kubernetes::manage_kernel_modules,
  Boolean $manage_sysctl_settings                       = $kubernetes::manage_sysctl_settings,
  Boolean $create_repos                                 = $kubernetes::repos::create_repos,
  Boolean $pin_packages                                 = $kubernetes::pin_packages,
  Integer $package_pin_priority                         = 32767,
  String $archive_checksum_type                         = 'sha256',
  Boolean $archive_cleanup                              = false,
  String $tmp_directory                                 = $kubernetes::tmp_directory,
  Optional[String] $http_proxy                          = $kubernetes::http_proxy,
  Optional[String] $https_proxy                         = $kubernetes::https_proxy,
  Optional[String] $no_proxy                            = $kubernetes::no_proxy,
  Boolean $container_runtime_use_proxy                  = $kubernetes::container_runtime_use_proxy,
  Variant[Stdlib::Unixpath, String] $containerd_socket  = $kubernetes::containerd_socket,
) {
  # Download directory for archives
  file { $tmp_directory:
    ensure => 'directory',
    mode   => '0750',
    owner  => 'root',
    group  => 'root',
    backup => false,
  }

  $kube_packages = ['kubelet', 'kubectl', 'kubeadm']

  if $disable_swap {
    exec { 'disable swap':
      path    => ['/usr/sbin/', '/usr/bin', '/bin', '/sbin'],
      command => 'swapoff -a',
      unless  => "awk '{ if (NR > 1) exit 1}' /proc/swaps",
    }
    file_line { 'remove swap in /etc/fstab':
      ensure            => absent,
      path              => '/etc/fstab',
      match             => '\sswap\s',
      match_for_absence => true,
      multiple          => true,
    }
  }

  if $manage_kernel_modules and $manage_sysctl_settings {
    kmod::load { 'overlay': }
    kmod::load { 'br_netfilter':
      before => Sysctl['net.bridge.bridge-nf-call-iptables'],
    }
    sysctl { 'net.bridge.bridge-nf-call-iptables':
      ensure => present,
      value  => '1',
      before => Sysctl['net.ipv4.ip_forward'],
    }
    sysctl { 'net.ipv4.ip_forward':
      ensure => present,
      value  => '1',
    }
  } elsif $manage_kernel_modules {
    kmod::load { 'overlay': }
    kmod::load { 'br_netfilter': }
  } elsif $manage_sysctl_settings {
    sysctl { 'net.bridge.bridge-nf-call-iptables':
      ensure => present,
      value  => '1',
      before => Sysctl['net.ipv4.ip_forward'],
    }
    sysctl { 'net.ipv4.ip_forward':
      ensure => present,
      value  => '1',
    }
  }

  if $container_runtime == 'docker' and $manage_docker == true {
    # procedure: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
    case $facts['os']['family'] {
      'Debian': {
        if $create_repos and $manage_docker {
          package { $docker_package_name:
            ensure  => $docker_version,
            require => Class['Apt::Update'],
          }
          if $pin_packages {
            file { '/etc/apt/preferences.d/docker':
              mode    => '0444',
              owner   => 'root',
              group   => 'root',
              content => template('kubernetes/docker_apt_package_pins.erb'),
              notify  => Service['docker'],
            }
          } else {
            file { '/etc/apt/preferences.d/docker':
              ensure => absent,
            }
          }
        } else {
          package { $docker_package_name:
            ensure => $docker_version,
          }
          if $pin_packages {
            fail('for safety reasons package pinning is only usable if you define the create_repos and manage_docker flags')
          }
        }

        file { '/etc/docker':
          ensure => 'directory',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
        }

        file { '/etc/docker/daemon.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('kubernetes/docker/daemon_debian.json.erb'),
          require => [File['/etc/docker'], Package[$docker_package_name]],
          notify  => Service['docker'],
        }
      }
      'RedHat': {
        package { $docker_package_name:
          ensure => $docker_version,
        }

        file { '/etc/docker':
          ensure => 'directory',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
        }

        file { '/etc/docker/daemon.json':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('kubernetes/docker/daemon_redhat.json.erb'),
          require => [File['/etc/docker'], Package[$docker_package_name]],
          notify  => Service['docker'],
        }
      }
      default: { notify { "The OS family ${facts['os']['family']} is not supported by this module": } }
    }

    file { '/etc/systemd/system/docker.service.d':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/etc/docker/daemon.json'],
      notify  => Exec['kubernetes-systemd-reload'],
    }

    if $container_runtime_use_proxy {
      file { '/etc/systemd/system/docker.service.d/http-proxy.conf':
        ensure  => file,
        notify  => [Exec['kubernetes-systemd-reload'], Service['docker']],
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template("${module_name}/http-proxy.conf.erb"),
      }
    }
  }
  elsif $container_runtime == 'cri_containerd' and $containerd_install_method == 'package' {
    # procedure: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
    case $facts['os']['family'] {
      'Debian': {
        if $create_repos {
          package { $containerd_package_name:
            ensure  => $containerd_version,
            require => Class['Apt::Update'],
          }
          if $pin_packages {
            file { '/etc/apt/preferences.d/containerd':
              mode    => '0444',
              owner   => 'root',
              group   => 'root',
              content => template('kubernetes/containerd_apt_package_pins.erb'),
              notify  => Service['containerd'],
            }
          } else {
            file { '/etc/apt/preferences.d/containerd':
              ensure => absent,
            }
          }
        } else {
          package { $containerd_package_name:
            ensure => $containerd_version,
          }
          if $pin_packages {
            fail('for safety reasons package pinning is only usable if you define the create_repos flag')
          }
        }

        file { '/etc/containerd':
          ensure => 'directory',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
        }

        if $containerd_config_source {
          $_containerd_config_content = undef
        } else {
          $_containerd_config_content = stdlib::deferrable_epp($containerd_config_template, {
              'containerd_plugins_registry' => $containerd_plugins_registry,
              'containerd_socket' => $containerd_socket,
              'containerd_sandbox_image' => $containerd_sandbox_image,
              'docker_cgroup_driver' => $docker_cgroup_driver,
              'containerd_default_runtime_name' => $containerd_default_runtime_name,
          })
        }
        # Generate using 'containerd config default'
        file { '/etc/containerd/config.toml':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $_containerd_config_content,
          source  => $containerd_config_source,
          require => [File['/etc/containerd'], Package[$containerd_package_name]],
          notify  => Service['containerd'],
        }
      }
      'RedHat': {
        package { $containerd_package_name:
          ensure => $containerd_version,
        }

        file { '/etc/containerd':
          ensure => 'directory',
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
        }

        if $containerd_config_source {
          $_containerd_config_content = undef
        } else {
          $_containerd_config_content = stdlib::deferrable_epp($containerd_config_template, {
              'containerd_plugins_registry' => $containerd_plugins_registry,
              'containerd_socket' => $containerd_socket,
              'containerd_sandbox_image' => $containerd_sandbox_image,
              'docker_cgroup_driver' => $docker_cgroup_driver,
              'containerd_default_runtime_name' => $containerd_default_runtime_name,
          })
        }
        # Generate using 'containerd config default'
        file { '/etc/containerd/config.toml':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $_containerd_config_content,
          source  => $containerd_config_source,
          require => [File['/etc/containerd'], Package[$containerd_package_name]],
          notify  => Service['containerd'],
        }
      }
      default: { notify { "The OS family ${facts['os']['family']} is not supported by this module": } }
    }
  }
  elsif $container_runtime == 'cri_containerd' and $containerd_install_method == 'archive' {
    if $runc_source_checksum and $runc_source_checksum =~ /.+/ {
      $runc_source_checksum_verify = true
      $runc_source_creates = undef
    } else {
      $runc_source_checksum_verify = false
      $runc_source_creates = ['/usr/bin/runc']
    }
    archive { '/usr/bin/runc':
      source          => $runc_source,
      checksum_type   => $archive_checksum_type,
      checksum        => $runc_source_checksum,
      checksum_verify => $runc_source_checksum_verify,
      extract         => false,
      cleanup         => $archive_cleanup,
      creates         => $runc_source_creates,
    }
    -> file { '/usr/bin/runc':
      mode => '0700',
    }

    file { '/etc/containerd':
      ensure => 'directory',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
    }

    # Generate using 'containerd config default'
    file { '/etc/containerd/config.toml':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => stdlib::deferrable_epp('kubernetes/containerd/config.toml.epp', {
          'containerd_plugins_registry'     => $containerd_plugins_registry,
          'containerd_socket'               => $containerd_socket,
          'containerd_sandbox_image'        => $containerd_sandbox_image,
          'docker_cgroup_driver'            => $docker_cgroup_driver,
          'containerd_default_runtime_name' => $containerd_default_runtime_name,
      }),
      require => [File['/etc/containerd'], Archive[$containerd_archive]],
      notify  => Service['containerd'],
    }

    if $containerd_archive_checksum and $containerd_archive_checksum =~ /.+/ {
      $containerd_archive_checksum_verify = true
      $containerd_archive_creates = undef
    } else {
      $containerd_archive_checksum_verify = false
      $containerd_archive_creates = ['/usr/bin/containerd']
    }
    archive { $containerd_archive:
      path            => "${tmp_directory}/${containerd_archive}",
      source          => $containerd_source,
      checksum_type   => $archive_checksum_type,
      checksum        => $containerd_archive_checksum,
      checksum_verify => $containerd_archive_checksum_verify,
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1 -C /usr/bin/',
      extract_path    => '/',
      cleanup         => $archive_cleanup,
      creates         => $containerd_archive_creates,
      notify          => Service['containerd'],
      require         => File[$tmp_directory],
    }
  }

  if $controller and $manage_etcd {
    if $etcd_install_method == 'wget' {
      if $etcd_archive_checksum and $etcd_archive_checksum =~ /.+/ {
        $etcd_archive_checksum_verify = true
        $etcd_archive_creates = undef
      } else {
        $etcd_archive_checksum_verify = false
        $etcd_archive_creates = ['/usr/local/bin/etcd', '/usr/local/bin/etcdctl']
      }
      archive { $etcd_archive:
        path            => "${tmp_directory}/${etcd_archive}",
        source          => $etcd_source,
        checksum_type   => $archive_checksum_type,
        checksum        => $etcd_archive_checksum,
        checksum_verify => $etcd_archive_checksum_verify,
        extract         => true,
        extract_command => 'tar xfz %s --strip-components=1 -C /usr/local/bin/',
        extract_path    => '/usr/local/bin',
        cleanup         => $archive_cleanup,
        creates         => $etcd_archive_creates,
        notify          => Service['etcd'],
        require         => File[$tmp_directory],
      }
    } else {
      package { $etcd_package_name:
        ensure => $etcd_version,
        notify => Service['etcd'],
      }
    }
  }

  if $create_repos and $facts['os']['family'] == 'Debian' {
    package { $kube_packages:
      ensure  => $kubernetes_package_version,
      require => Class['Apt::Update'],
    }
    if $pin_packages {
      file { '/etc/apt/preferences.d/kubernetes':
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('kubernetes/kubernetes_apt_package_pins.erb'),
      }
    } else {
      file { '/etc/apt/preferences.d/kubernetes':
        ensure => absent,
      }
    }
  } else {
    package { $kube_packages:
      ensure => $kubernetes_package_version,
    }
    if $pin_packages {
      fail('package pinning is not implemented on this platform')
    }
  }
}
