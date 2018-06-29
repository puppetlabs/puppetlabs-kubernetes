# Kubernetes params

class kubernetes::params {

$kubernetes_version = '1.10.2'
case $::osfamily {
  'Debian' : {
    $kubernetes_package_version = "${kubernetes_version}-00"
    $docker_version = '17.03.0~ce-0~ubuntu-xenial'
  }
  'RedHat' : {
    $kubernetes_package_version = $kubernetes_version
    $docker_version = '17.03.1.ce-1.el7.centos'
  }
  default: { notify {"The OS family ${::osfamily} is not supported by this module":} }
}
$container_runtime = 'docker'
$containerd_version = '1.1.0'
$etcd_version = '3.1.12'
$kubernetes_fqdn = 'kubernetes'
$controller = false
$bootstrap_controller = false
$worker =  false
$kube_api_advertise_address = undef
$etcd_ip = undef
$etcd_initial_cluster = undef
$etcd_ca_key = undef
$etcd_ca_crt = undef
$etcdclient_key = undef
$etcdclient_crt = undef
$cni_network_provider = undef
$cni_network_provider_rbac = undef
$calicoctl = undef
$cni_pod_cidr = undef
$cni_pod_cidr_allocate = undef
$cni_pod_cidr_mask = undef
$install_dashboard = false
$schedule_on_controller = false
$node_label = $::hostname
$api_server_count = undef
$etcd_peers = undef
$etcdserver_key = undef
$etcdpeer_crt = undef
$etcdserver_crt = undef
$etcdpeer_key = undef
$token = undef
$discovery_token_hash = undef
$kubernetes_ca_crt = undef
$kubernetes_ca_key = undef
$sa_key = undef
$sa_pub = undef
$apiserver_cert_extra_sans = []
$apiserver_extra_arguments = []
$service_cidr = '10.96.0.0/12'
$controller_address = undef
$cloud_provider = undef
}
