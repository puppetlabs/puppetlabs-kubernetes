# This class adds the files for the Kubernetes manifests, pki etc

class kubernetes::config (

  String $kubernetes_version                                       = $kubernetes::kubernetes_version,
  String $container_runtime                                        = $kubernetes::container_runtime,
  Optional[String] $cni_cluster_cidr                               = $kubernetes::cni_cluster_cidr,
  Optional[Boolean] $cni_node_cidr                                 = $kubernetes::cni_node_cidr,
  Optional[String] $cluster_service_cidr                           = $kubernetes::cluster_service_cidr,
  String $kube_dns_ip                                              = $kubernetes::kube_dns_ip,
  String $kube_dns_version                                         = $kubernetes::kube_dns_version,
  String $kube_proxy_version                                       = $kubernetes::kube_proxy_version,
  String $kubernetes_fqdn                                          = $kubernetes::kubernetes_fqdn,
  Boolean $controller                                              = $kubernetes::controller,
  Boolean $bootstrap_controller                                    = $kubernetes::bootstrap_controller,
  Optional[String] $bootstrap_controller_ip                        = $kubernetes::bootstrap_controller_ip,
  Boolean $worker                                                  = $kubernetes::worker,
  Optional[String] $node_name                                      = $::hostname,
  Optional[String] $kube_api_advertise_address                     = $kubernetes::kube_api_advertise_address,
  String $etcd_version                                             = $kubernetes::etcd_version,
  Optional[String] $etcd_ip                                        = $kubernetes::etcd_ip,
  Optional[String] $etcd_initial_cluster                           = $kubernetes::etcd_initial_cluster,
  Optional[String] $bootstrap_token                                = $kubernetes::bootstrap_token,
  Optional[String] $bootstrap_token_name                           = $kubernetes::bootstrap_token_name,
  Optional[String] $bootstrap_token_description                    = $kubernetes::bootstrap_token_description,
  Optional[String] $bootstrap_token_id                             = $kubernetes::bootstrap_token_id,
  Optional[String] $bootstrap_token_secret                         = $kubernetes::bootstrap_token_secret,
  Optional[String] $bootstrap_token_usage_bootstrap_authentication = $kubernetes::bootstrap_token_usage_bootstrap_authentication,
  Optional[String] $bootstrap_token_expiration                     = $kubernetes::bootstrap_token_expiration,
  Optional[String] $bootstrap_token_usage_bootstrap_signing        = $kubernetes::bootstrap_token_usage_bootstrap_signing,
  Optional[String] $certificate_authority_data                     = $kubernetes::certificate_authority_data,
  Optional[String] $client_certificate_data_controller             = $kubernetes::client_certificate_data_controller,
  Optional[String] $client_certificate_data_controller_manager     = $kubernetes::client_certificate_data_controller_manager,
  Optional[String] $client_certificate_data_scheduler              = $kubernetes::client_certificate_data_scheduler,
  Optional[String] $client_certificate_data_worker                 = $kubernetes::client_certificate_data_worker,
  Optional[String] $client_certificate_data_admin                  = $kubernetes::client_certificate_data_admin,
  Optional[String] $client_key_data_controller                     = $kubernetes::client_key_data_controller,
  Optional[String] $client_key_data_controller_manager             = $kubernetes::client_key_data_controller_manager,
  Optional[String] $client_key_data_scheduler                      = $kubernetes::client_key_data_scheduler,
  Optional[String] $client_key_data_worker                         = $kubernetes::client_key_data_worker,
  Optional[String] $client_key_data_admin                          = $kubernetes::client_key_data_admin,
  Optional[String] $apiserver_kubelet_client_crt                   = $kubernetes::apiserver_kubelet_client_crt,
  Optional[String] $apiserver_kubelet_client_key                   = $kubernetes::apiserver_kubelet_client_key,
  Optional[String] $apiserver_crt                                  = $kubernetes::apiserver_crt,
  Optional[String] $apiserver_key                                  = $kubernetes::apiserver_key,
  Array $apiserver_extra_arguments                                 = $kubernetes::apiserver_extra_arguments,
  Optional[String] $ca_crt                                         = $kubernetes::ca_crt,
  Optional[String] $ca_key                                         = $kubernetes::ca_key,
  Optional[String] $front_proxy_ca_crt                             = $kubernetes::front_proxy_ca_crt,
  Optional[String] $front_proxy_ca_key                             = $kubernetes::front_proxy_ca_key,
  Optional[String] $front_proxy_client_crt                         = $kubernetes::front_proxy_client_crt,
  Optional[String] $front_proxy_client_key                         = $kubernetes::front_proxy_client_key,
  Optional[String] $sa_key                                         = $kubernetes::sa_key,
  Optional[String] $sa_pub                                         = $kubernetes::sa_pub,

){

  if $controller {
  $kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/addons', '/etc/kubernetes/secrets/'] # lint:ignore:140chars
  $kube_cni_dirs = [ '/etc/cni', '/etc/cni/net.d'] # lint:ignore:140chars
  $kube_etc_files = ['admin.conf', 'controller-manager.conf', 'kubelet.conf', 'scheduler.conf'] # lint:ignore:140chars
  $kube_manifest_files = ['etcd.yaml', 'kube-apiserver.yaml', 'kube-controller-manager.yaml', 'kube-scheduler.yaml', 'clusterRoleBinding.yaml'] # lint:ignore:140chars
  $kube_addons_files = ['kube-dns-sa.yaml','kube-dns-deployment.yaml', 'kube-dns-service.yaml', 'kube-proxy-sa.yaml', 'kube-proxy-daemonset.yaml', 'kube-proxy.yaml'] # lint:ignore:140chars
  $kube_pki_files = ['apiserver.crt', 'apiserver-kubelet-client.crt', 'ca.crt', 'front-proxy-ca.crt', 'front-proxy-client.crt', 'sa.key',
                    'apiserver.key',  'apiserver-kubelet-client.key', 'ca.key', 'front-proxy-ca.key', 'front-proxy-client.key', 'sa.pub'] # lint:ignore:140chars
  }

  if $worker {
  $kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki'] # lint:ignore:140chars
  $kube_cni_dirs = [ '/etc/cni', '/etc/cni/net.d'] # lint:ignore:140chars
  $kube_etc_files = ['kubelet.conf']
  $kube_pki_files = ['ca.crt']
  $kube_addons_files = []
  $kube_manifest_files = []
  }

  file {$kube_cni_dirs:
    ensure => 'directory',
  }

  file { $kube_dirs:
    ensure => 'directory',
  }

  $kube_etc_files.each | String $etc_file | {
    file { "/etc/kubernetes/${etc_file}":
      ensure  => present,
      content => template("kubernetes/${etc_file}.erb"),
      require => File['/etc/kubernetes'],
      }
  }

  $kube_manifest_files.each | String $man_file | {
    file { "/etc/kubernetes/manifests/${man_file}":
      ensure  => present,
      content => template("kubernetes/${man_file}.erb"),
      require => File['/etc/kubernetes/manifests'],
      }
    }

  $kube_pki_files.each | String $pki_file | {
    file { "/etc/kubernetes/pki/${pki_file}":
      ensure  => present,
      content => template("kubernetes/pki/${pki_file}.erb"),
      require => File['/etc/kubernetes/pki'],
      }
  }

  if $controller {

  #TODO fix secuirty issue that the bootstarp token is left on the server.

    file {'/etc/kubernetes/secrets/bootstraptoken.yaml':
      ensure  => present,
      content => template('kubernetes/secrets/bootstraptoken.yaml.erb'),
      require => File['/etc/kubernetes/secrets/'],
    }

    $kube_addons_files.each | String $addons_file | {
      file { "/etc/kubernetes/addons/${addons_file}":
        ensure  => present,
        content => template("kubernetes/addons/${addons_file}.erb"),
        require => File['/etc/kubernetes/addons'],
        }
    }

    file {'/root/admin.conf':
      ensure  => present,
      content => template('kubernetes/admin.conf.erb'),
    }

    file { '/etc/profile.d/kubectl.sh':
      mode    => '0644',
      content => 'export KUBECONFIG=$HOME/admin.conf',
    }
  }
}
