#Calss kubernetes config, populates config files with params to bootstrap cluster
class kubernetes::config (

  Boolean $manage_etcd = $kubernetes::manage_etcd,
  String $kubernetes_version  = $kubernetes::kubernetes_version,
  String $etcd_ca_key = $kubernetes::etcd_ca_key,
  String $etcd_ca_crt = $kubernetes::etcd_ca_crt,
  String $etcdclient_key = $kubernetes::etcdclient_key,
  String $etcdclient_crt = $kubernetes::etcdclient_crt,
  String $etcdserver_crt = $kubernetes::etcdserver_crt,
  String $etcdserver_key = $kubernetes::etcdserver_key,
  String $etcdpeer_crt = $kubernetes::etcdpeer_crt,
  String $etcdpeer_key = $kubernetes::etcdpeer_key,
  Array $etcd_peers = $kubernetes::etcd_peers,
  String $etcd_ip = $kubernetes::etcd_ip,
  String $cni_pod_cidr = $kubernetes::cni_pod_cidr,
  String $kube_api_advertise_address = $kubernetes::kube_api_advertise_address,
  String $etcd_initial_cluster = $kubernetes::etcd_initial_cluster,
  Integer $api_server_count = $kubernetes::api_server_count,
  String $etcd_version = $kubernetes::etcd_version,
  String $token = $kubernetes::token,
  String $discovery_token_hash = $kubernetes::discovery_token_hash,
  String $kubernetes_ca_crt = $kubernetes::kubernetes_ca_crt,
  String $kubernetes_ca_key = $kubernetes::kubernetes_ca_key,
  String $container_runtime = $kubernetes::container_runtime,
  String $sa_pub = $kubernetes::sa_pub,
  String $sa_key = $kubernetes::sa_key,
  Optional[Array] $apiserver_cert_extra_sans = $kubernetes::apiserver_cert_extra_sans,
  Optional[Array] $apiserver_extra_arguments = $kubernetes::apiserver_extra_arguments,
  Optional[Array] $kubelet_extra_arguments = $kubernetes::kubelet_extra_arguments,
  String $service_cidr = $kubernetes::service_cidr,
  String $node_label = $kubernetes::node_label,
  Optional[String] $cloud_provider = $kubernetes::cloud_provider,
  Optional[String] $cloud_config = $kubernetes::cloud_config,
  Optional[Hash] $kubeadm_extra_config = $kubernetes::kubeadm_extra_config,
  Optional[Hash] $kubelet_extra_config = $kubernetes::kubelet_extra_config,
  String $image_repository = $kubernetes::image_repository,
) {

  $kube_dirs = ['/etc/kubernetes','/etc/kubernetes/manifests','/etc/kubernetes/pki','/etc/kubernetes/pki/etcd']
  $etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
  $pki = ['ca.crt', 'ca.key','sa.pub','sa.key']
  $kube_dirs.each | String $dir |  {
    file  { $dir :
      ensure => directory,

    }
  }

  if $manage_etcd {
    $etcd.each | String $etcd_files | {
      file { "/etc/kubernetes/pki/etcd/${etcd_files}":
        ensure  => present,
        mode    => '0644',
        content => template("kubernetes/etcd/${etcd_files}.erb"),
      }
    }
    file { '/etc/systemd/system/etcd.service':
      ensure  => present,
      content => template('kubernetes/etcd/etcd.service.erb'),
    }
  }

  $pki.each | String $pki_files | {
    file {"/etc/kubernetes/pki/${pki_files}":
      ensure  => present,
      mode    => '0644',
      content => template("kubernetes/pki/${pki_files}.erb"),
    }
  }

  # The alpha1 schema puts Kubelet configuration in a different place.
  $kubelet_extra_config_alpha1 = {
    'kubeletConfiguration' => {
      'baseConfig' => $kubelet_extra_config,
    },
  }

  # to_yaml emits a complete YAML document, so we must remove the leading '---'
  $kubeadm_extra_config_yaml = regsubst(to_yaml($kubeadm_extra_config), '^---\n', '')
  $kubelet_extra_config_yaml = regsubst(to_yaml($kubelet_extra_config), '^---\n', '')
  $kubelet_extra_config_alpha1_yaml = regsubst(to_yaml($kubelet_extra_config_alpha1), '^---\n', '')

  if $kubernetes_version =~ /1.1(0|1)/ {
    $template = 'alpha1'
  } else {
    $template = 'alpha3'
  }

  file { '/etc/kubernetes/config.yaml':
    ensure  => present,
    content => template("kubernetes/config-${template}.yaml.erb"),
  }

}
