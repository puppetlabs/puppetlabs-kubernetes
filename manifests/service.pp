# Puppet class that controls the Kubelet service

class kubernetes::service (
  String $container_runtime         = $kubernetes::container_runtime,
  Boolean $controller               = $kubernetes::controller,
  Boolean $manage_docker            = $kubernetes::manage_docker,
  Boolean $manage_etcd              = $kubernetes::manage_etcd,
  Optional[String] $cloud_provider  = $kubernetes::cloud_provider,
){
  file { '/etc/systemd/system/kubelet.service.d':
    ensure => directory,
  }

  exec { 'kubernetes-systemd-reload':
    path        => '/bin',
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  case $container_runtime {
    'docker': {

      if $manage_docker == true {
        service { 'docker':
          ensure => running,
          enable => true,
        }
      }

    }

    'cri_containerd': {
      file { '/etc/systemd/system/kubelet.service.d/0-containerd.conf':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('kubernetes/0-containerd.conf.erb'),
        require => File['/etc/systemd/system/kubelet.service.d'],
        notify  => Exec['kubernetes-systemd-reload'],
      }

      file { '/etc/systemd/system/containerd.service':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('kubernetes/containerd.service.erb'),
        notify  => Exec['kubernetes-systemd-reload'],
      }

      service { 'containerd':
        ensure  => running,
        enable  => true,
        require => File['/etc/systemd/system/kubelet.service.d/0-containerd.conf'],
      }
    }

    default: {
      fail(translate('Please specify a valid container runtime'))
    }
  }

  if $controller and $manage_etcd {
    service { 'etcd':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/etcd.service']
    }
  }

  if $cloud_provider {
    file { '/etc/systemd/system/kubelet.service.d/20-cloud.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kubernetes/20-cloud.conf.erb'),
      require => File['/etc/systemd/system/kubelet.service.d'],
      notify  => Exec['kubernetes-systemd-reload'],
    }
  }
}
