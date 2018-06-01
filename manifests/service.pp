# Puppet class that controls the Kubelet service

class kubernetes::service (

  String $container_runtime = $kubernetes::container_runtime,
  Boolean $controller = $kubernetes::controller,
){

  case $container_runtime {
    'docker': {
      service { 'docker':
        ensure => running,
        enable => true,
      }

    }

  'cri_containerd': {
    file {'/etc/systemd/system/kubelet.service.d':
      ensure => directory,
      before => File['/etc/systemd/system/kubelet.service.d/0-containerd.conf'],
    }

    file {'/etc/systemd/system/kubelet.service.d/0-containerd.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kubernetes/0-containerd.conf.erb'),
      require => File['/etc/systemd/system/kubelet.service.d'],
      notify  => Exec['Reload systemd'],
    }

    file {'/etc/systemd/system/containerd.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kubernetes/containerd.service.erb'),
      notify  => Exec['Reload systemd'],
    }

    exec { 'Reload systemd':
      path        => '/bin',
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      }

    service {'containerd':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/kubelet.service.d/0-containerd.conf']
      }
    }

    default: {
      fail(translate('Please specify a valid container runtime'))
    }
  }

  if $controller {
    service { 'etcd':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/etcd.service']
    }
  }
}
