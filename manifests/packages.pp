# Class kubernetes packages

class kubernetes::packages (

  String $kubernetes_version                   = $kubernetes::kubernetes_version,
  String $container_runtime                    = $kubernetes::container_runtime,
  Optional[String] $docker_version             = $kubernetes::docker_version,
  String $etcd_version                         = $kubernetes::etcd_version,
  Optional[String] $containerd_version         = $kubernetes::containerd_version,
  Boolean $controller                          = $kubernetes::controller,

) {

  $kube_packages = ['kubelet', 'kubectl', 'kubeadm']
  $containerd_archive = "containerd-${containerd_version}.linux-amd64.tar.gz"
  $containerd_source = "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}"
  $etcd_archive = "etcd-v${etcd_version}-linux-amd64.tar.gz"
  $etcd_source = "https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}"

  if $::osfamily == 'RedHat' {
    exec { 'set up bridge-nf-call-iptables':
      path    => ['/usr/sbin/', '/usr/bin', '/bin'],
      command => 'modprobe br_netfilter',
      creates => '/proc/sys/net/bridge/bridge-nf-call-iptables',
      before  => File_line['set 1 /proc/sys/net/bridge/bridge-nf-call-iptables'],
    }

    file { '/proc/sys/net/bridge/bridge-nf-call-iptables':
      # path    => '/proc/sys/net/bridge/bridge-nf-call-iptables',
      # replace => true,
      # line    => '1',
      # match   => '0',
      contents => '1',
      require => Exec['set up bridge-nf-call-iptables'],
    }
  }


  if $container_runtime == 'docker' {
    case $::osfamily {
      'Debian','RedHat' : {
        package { 'docker-engine':
          ensure => $docker_version,
        }
      }

    default: { notify {"The OS family ${::osfamily} is not supported by this module":} }
    }
  }

  elsif $container_runtime == 'cri_containerd' {

    wget::fetch { 'download runc binary':
      source      => 'https://github.com/opencontainers/runc/releases/download/v1.0.0-rc5/runc.amd64',
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

  if $controller {
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
    ensure => $kubernetes_version,
  }

}
