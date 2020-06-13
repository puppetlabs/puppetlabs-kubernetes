# Class kubernetes packages

class kubernetes::packages (
  String $kubernetes_package_version            = $kubernetes::kubernetes_package_version,
  String $container_runtime                     = $kubernetes::container_runtime,
  Boolean $manage_docker                        = $kubernetes::manage_docker,
  Boolean $manage_etcd                          = $kubernetes::manage_etcd,
  Optional[String] $docker_version              = $kubernetes::docker_version,
  Optional[String] $docker_package_name         = $kubernetes::docker_package_name,
  Optional[String] $docker_storage_driver       = $kubernetes::docker_storage_driver,
  Optional[String] $docker_cgroup_driver        = $kubernetes::cgroup_driver,
  Optional[Array] $docker_storage_opts          = $kubernetes::docker_storage_opts,
  Optional[String] $docker_extra_daemon_config  = $kubernetes::docker_extra_daemon_config,
  String $docker_log_max_file                   = $kubernetes::docker_log_max_file,
  String $docker_log_max_size                   = $kubernetes::docker_log_max_size,
  Boolean $controller                           = $kubernetes::controller,
  Optional[String] $containerd_archive          = $kubernetes::containerd_archive,
  Optional[String] $containerd_archive_checksum = $kubernetes::containerd_archive_checksum,
  Optional[String] $containerd_source           = $kubernetes::containerd_source,
  String $etcd_archive                          = $kubernetes::etcd_archive,
  Optional[String] $etcd_archive_checksum       = $kubernetes::etcd_archive_checksum,
  String $etcd_version                          = $kubernetes::etcd_version,
  String $etcd_source                           = $kubernetes::etcd_source,
  String $etcd_package_name                     = $kubernetes::etcd_package_name,
  String $etcd_install_method                   = $kubernetes::etcd_install_method,
  Optional[String] $runc_source                 = $kubernetes::runc_source,
  Optional[String] $runc_source_checksum        = $kubernetes::runc_source_checksum,
  Boolean $disable_swap                         = $kubernetes::disable_swap,
  Boolean $manage_kernel_modules                = $kubernetes::manage_kernel_modules,
  Boolean $manage_sysctl_settings               = $kubernetes::manage_sysctl_settings,
  Boolean $create_repos                         = $kubernetes::repos::create_repos,
  Boolean $pin_packages                         = $kubernetes::pin_packages,
  Integer $package_pin_priority                 = 32767,
  String $archive_checksum_type                 = 'sha256',
) {

  $tmp_directory = '/var/tmp/puppetlabs-kubernetes'

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
  }

  if $manage_kernel_modules and $manage_sysctl_settings {
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
          }else {
            file { '/etc/apt/preferences.d/docker':
              ensure => absent,
            }
          }
        }else {
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
          require => [ File['/etc/docker'], Package[$docker_package_name] ],
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
          require => [ File['/etc/docker'], Package[$docker_package_name] ],
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

  }

  elsif $container_runtime == 'cri_containerd' {
    if $runc_source_checksum and $runc_source_checksum =~ /.+/ {
      $runc_source_checksum_verify = true
      $runc_source_creates = undef
    }else {
      $runc_source_checksum_verify = false
      $runc_source_creates = ['/usr/bin/runc']
    }
    archive { '/usr/bin/runc':
      source          => $runc_source,
      checksum_type   => $archive_checksum_type,
      checksum        => $runc_source_checksum,
      checksum_verify => $runc_source_checksum_verify,
      extract         => false,
      cleanup         => false,
      creates         => $runc_source_creates,
    }
    -> file { '/usr/bin/runc':
      mode => '0700'
    }

    if $containerd_archive_checksum and $containerd_archive_checksum =~ /.+/ {
      $containerd_archive_checksum_verify = true
      $containerd_archive_creates = undef
    }else {
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
      cleanup         => true,
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
      }else {
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
        cleanup         => true,
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
    }else {
      file { '/etc/apt/preferences.d/kubernetes':
        ensure => absent,
      }
    }
  }else {
    package { $kube_packages:
      ensure => $kubernetes_package_version,
    }
    if $pin_packages {
      fail('package pinning is not implemented on this platform')
    }
  }

}
