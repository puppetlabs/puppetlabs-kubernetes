# @summary
#   Puppet class that controls the Kubelet service
#
# @param container_runtime
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker"
#   Defaults to cri_containerd
# @param container_runtime_use_proxy
#   Configure whether the container runtime should be configured to use a proxy.
#   If set to true, the container runtime will use the http_proxy, https_proxy and
#   no_proxy values.
#   Defaults to false
# @param containerd_install_method
#   Whether to install containerd via archive or package.
#   Defaults to archive
# @param controller
#   This is a bool that sets the node as a Kubernetes controller
#   Defaults to false
# @param manage_docker
#   Whether or not to install Docker repositories and packages via this module.
#   Defaults to true.
# @param manage_etcd
#   When set to true, etcd will be downloaded from the specified source URL.
#   Defaults to true.
# @param etcd_install_method
#   The method on how to install etcd. Can be either wget (using etcd_source) or package (using $etcd_package_name)
#   Defaults to wget
# @param kubernetes_version
#   The version of Kubernetes containers you want to install.
#   ie api server,
#   Defaults to  1.10.2
# @param cloud_provider
#   The name of the cloud provider of the cloud provider configured in /etc/kubernetes/cloud-config
#   Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#   Defaults to undef
# @param cloud_config
#   The file location of the cloud config to be used by cloud_provider [*For use with v1.12 and above*]
#   Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#   Defaults to undef
# @param http_proxy
#   Configure the HTTP_PROXY environment variable
#   Defaults to undef
# @param https_proxy
#   Configure the HTTPS_PROXY environment variable
#   Defaults to undef
# @param no_proxy
#   Configure the NO_PROXY environment variable
#   Defaults to undef
# @param kubelet_use_proxy
#   Configure whether the kubelet should be configured to use a proxy.
#   If set to true, the kubelet will use the http_proxy, https_proxy and
#   no_proxy values.
#   Defaults to false
#
class kubernetes::service (
  String $container_runtime                             = $kubernetes::container_runtime,
  Boolean $container_runtime_use_proxy                  = $kubernetes::container_runtime_use_proxy,
  Enum['archive','package'] $containerd_install_method  = $kubernetes::containerd_install_method,
  Boolean $controller                                   = $kubernetes::controller,
  Boolean $manage_docker                                = $kubernetes::manage_docker,
  Boolean $manage_etcd                                  = $kubernetes::manage_etcd,
  String $etcd_install_method                           = $kubernetes::etcd_install_method,
  String $kubernetes_version                            = $kubernetes::kubernetes_version,
  Optional[String] $cloud_provider                      = $kubernetes::cloud_provider,
  Optional[String] $cloud_config                        = $kubernetes::cloud_config,
  Optional[String] $http_proxy                          = $kubernetes::http_proxy,
  Optional[String] $https_proxy                         = $kubernetes::https_proxy,
  Optional[String] $no_proxy                            = $kubernetes::no_proxy,
  Boolean $kubelet_use_proxy                            = $kubernetes::kubelet_use_proxy,
) {
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
          ensure  => running,
          enable  => true,
          require => Exec['kubernetes-systemd-reload'],
        }
      }
    }

    'cri_containerd': {
      $containerd_service_require = Exec['kubernetes-systemd-reload']
      unless $containerd_install_method == 'package' {
        file { '/etc/systemd/system/kubelet.service.d/0-containerd.conf':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('kubernetes/0-containerd.conf.erb'),
          require => File['/etc/systemd/system/kubelet.service.d'],
          notify  => [Exec['kubernetes-systemd-reload'], Service['containerd']],
        }

        file { '/etc/systemd/system/containerd.service':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('kubernetes/containerd.service.erb'),
          notify  => [Exec['kubernetes-systemd-reload'], Service['containerd']],
        }
      }

      file { '/etc/systemd/system/containerd.service.d':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        notify => Exec['kubernetes-systemd-reload'],
      }

      if $container_runtime_use_proxy {
        file { '/etc/systemd/system/containerd.service.d/http-proxy.conf':
          ensure  => file,
          notify  => [Exec['kubernetes-systemd-reload'], Service['containerd']],
          owner   => root,
          group   => root,
          mode    => '0644',
          content => template("${module_name}/http-proxy.conf.erb"),
        }
      }

      service { 'containerd':
        ensure  => running,
        enable  => true,
        require => $containerd_service_require,
      }
    }

    default: {
      fail('Please specify a valid container runtime')
    }
  }

  if $controller and $manage_etcd {
    service { 'etcd':
      ensure => running,
      enable => true,
    }
    File <|
    path == '/etc/systemd/system/kubelet.service.d' or
    path == '/etc/default/etcd' or
    path == '/etc/systemd/system/etcd.service'
    |> ~> Service['etcd']

    if $etcd_install_method == 'wget' {
      exec { 'systemctl-daemon-reload-etcd':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File['/etc/systemd/system/etcd.service'],
        notify      => Service['etcd'],
      }
    }
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

  if $kubelet_use_proxy {
    file { '/etc/systemd/system/kubelet.service.d/http-proxy.conf':
      ensure  => file,
      notify  => [Exec['kubernetes-systemd-reload'], Service['kubelet']],
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template("${module_name}/http-proxy.conf.erb"),
    }
  }

  service { 'kubelet':
    enable  => true,
    require => Exec['kubernetes-systemd-reload'],
  }
}
