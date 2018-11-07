# Class kubernetes packages

class kubernetes::packages (

  String $kubernetes_package_version           = $kubernetes::kubernetes_package_version,
  String $container_runtime                    = $kubernetes::container_runtime,
  Boolean $manage_docker                       = $kubernetes::manage_docker,
  Boolean $manage_etcd                         = $kubernetes::manage_etcd,
  Optional[String] $docker_version             = $kubernetes::docker_version,
  Optional[String] $docker_package_name        = $kubernetes::docker_package_name,
  Boolean $controller                          = $kubernetes::controller,
  Optional[String] $containerd_archive         = $kubernetes::containerd_archive,
  Optional[String] $containerd_source          = $kubernetes::containerd_source,
  String $etcd_archive                         = $kubernetes::etcd_archive,
  String $etcd_source                          = $kubernetes::etcd_source,
  Optional[String] $runc_source                = $kubernetes::runc_source,
  Boolean $disable_swap                        = $kubernetes::disable_swap,

) {

  $kube_packages = ['kubelet', 'kubectl', 'kubeadm']

  if $disable_swap {
    exec {'disable swap':
      path    => ['/usr/sbin/', '/usr/bin', '/bin','/sbin'],
      command => 'swapoff -a',
      unless  => "awk '{ if (NR > 1) exit 1}' /proc/swaps",
    }
  }

  exec { 'set up bridge-nf-call-iptables':
    path    => ['/usr/sbin/', '/usr/bin', '/bin','/sbin'],
    command => 'modprobe br_netfilter',
    creates => '/proc/sys/net/bridge/bridge-nf-call-iptables',
    before  => File_line['set 1 /proc/sys/net/bridge/bridge-nf-call-iptables'],
  }

  file_line { 'set 1 /proc/sys/net/bridge/bridge-nf-call-iptables':
    path    => '/proc/sys/net/bridge/bridge-nf-call-iptables',
    replace => true,
    line    => '1',
    match   => '0',
    require => Exec['set up bridge-nf-call-iptables'],
  }

  exec { 'sysctl -w net.ipv4.ip_forward=1':
    path    => ['/usr/sbin/', '/usr/bin', '/bin','/sbin'],
    command => 'sysctl -w net.ipv4.ip_forward=1',
    unless  => 'grep 1 /proc/sys/net/ipv4/ip_forward',
  }


  if $container_runtime == 'docker' and $manage_docker == true {
    case $::osfamily {
      'Debian': {
        package { $docker_package_name:
          ensure => $docker_version,
        }
      }
      'RedHat': {
        package { $docker_package_name:
          ensure => $docker_version,
        }
        file_line { 'set systemd cgroup docker':
          path    => '/usr/lib/systemd/system/docker.service',
          line    => 'ExecStart=/usr/bin/dockerd --exec-opt native.cgroupdriver=systemd',
          match   => 'ExecStart',
          require => Package[$docker_package_name],
        }
      }
    default: { notify {"The OS family ${::osfamily} is not supported by this module":} }
    }
  }

  elsif $container_runtime == 'cri_containerd' {

    wget::fetch { 'download runc binary':
      source      => $runc_source,
      destination => '/usr/bin/runc',
      timeout     => 0,
      verbose     => false,
      unless      => "test $(ls -A /usr/bin/runc 2>/dev/null)",
      before      => File['/usr/bin/runc'],
    }

    file {'/usr/bin/runc':
      mode => '0700'
    }

    archive { $containerd_archive:
      path            => "/${containerd_archive}",
      source          => $containerd_source,
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1 -C /usr/bin/',
      extract_path    => '/',
      cleanup         => true,
      creates         => '/usr/bin/containerd'
    }
  }

  if $controller and $manage_etcd {
    archive { $etcd_archive:
      path            => "/${etcd_archive}",
      source          => $etcd_source,
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1 -C /usr/local/bin/',
      extract_path    => '/usr/local/bin',
      cleanup         => true,
      creates         => ['/usr/local/bin/etcd','/usr/local/bin/etcdctl']
    }
  }

  package { $kube_packages:
    ensure => $kubernetes_package_version,
  }

}
