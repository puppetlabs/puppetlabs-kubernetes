# Puppet class that controls the Kubelet service

class kubernetes::service (
  String $container_runtime         = $kubernetes::container_runtime,
  Boolean $controller               = $kubernetes::controller,
  Boolean $manage_docker            = $kubernetes::manage_docker,
  Boolean $manage_etcd              = $kubernetes::manage_etcd,
  String $kubernetes_version        = $kubernetes::kubernetes_version,
  Optional[String] $cloud_provider  = $kubernetes::cloud_provider,
  Optional[String] $cloud_config    = $kubernetes::cloud_config,
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
      ensure => running,
      enable => true,
    }
    File <| path == '/etc/systemd/system/kubelet.service.d' or path == '/etc/default/etcd' |> ~> Service['etcd']
  }

  # RedHat needs to have CPU and Memory accounting enabled to avoid systemd proc errors
  if $facts['os']['family'] == 'RedHat' {
    file { '/etc/systemd/system/kubelet.service.d/11-cgroups.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "[Service]\nCPUAccounting=true\nMemoryAccounting=true\n",
      require => File['/etc/systemd/system/kubelet.service.d'],
      notify  => Exec['kubernetes-systemd-reload'],
    }
  }

  # v1.12 and up get the cloud config parameters from config file
  if $kubernetes_version =~ /1.1(0|1)/ and !empty($cloud_provider) {
    # Cloud config is not used by all providers, but will cause service startup fail if specified but missing
    if empty($cloud_config) {
      $kubelet_extra_args = "--cloud-provider=${cloud_provider}"
    } else {
      $kubelet_extra_args = "--cloud-provider=${cloud_provider} --cloud-config=${cloud_config}"
    }
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

  service { 'kubelet':
    enable => true
  }
}
