# Kubernetes params

class kubernetes::params {

$kubernetes_version = '1.9.2'
case $::osfamily {
  'Debian' : {
    $kubernetes_package_version = "${kubernetes_version}-00"
    $docker_package_version = '1.12.0-0~xenial'
    $cni_version = '0.6.0-00'
  }
  'RedHat' : {
    $kubernetes_package_version = $kubernetes_version
    $docker_package_version = '1.12.6'
    $cni_version = '0.6.0'
  }
  default: { notify {"The OS family ${::os_family} is not supported by this module":} }
}

$kube_dns_version = '1.14.2'
$kube_proxy_version = $kubernetes_version
$container_runtime = 'docker'
$docker_package_name = 'docker-engine'
$package_pin = true
$cni_package_name = 'kubernetes-cni'
$kubernetes_fqdn = 'kubernetes'
$controller = false
$bootstrap_controller = false
$bootstrap_controller_ip = undef
$worker = false
$kube_api_advertise_address = undef
$etcd_version = '3.1.11'
$etcd_ip = undef
$etcd_initial_cluster = undef
$bootstrap_token = undef
$bootstrap_token_name = undef
$bootstrap_token_description = undef
$bootstrap_token_id = undef
$bootstrap_token_secret = undef
$bootstrap_token_usage_bootstrap_authentication = undef
$bootstrap_token_expiration = undef
$bootstrap_token_usage_bootstrap_signing = undef
$certificate_authority_data = undef
$client_certificate_data_controller = undef
$client_certificate_data_controller_manager = undef
$client_certificate_data_scheduler = undef
$client_certificate_data_worker = undef
$client_certificate_data_admin = undef
$client_key_data_controller = undef
$client_key_data_controller_manager = undef
$client_key_data_scheduler = undef
$client_key_data_worker = undef
$client_key_data_admin = undef
$apiserver_kubelet_client_crt = undef
$apiserver_kubelet_client_key = undef
$apiserver_crt = undef
$apiserver_key = undef
$apiserver_extra_arguments = []
$apiserver_extra_volumes = []
$ca_crt = undef
$ca_key = undef
$front_proxy_ca_crt = undef
$front_proxy_ca_key = undef
$front_proxy_client_crt = undef
$front_proxy_client_key = undef
$sa_key = undef
$sa_pub = undef
$cni_cluster_cidr = undef
$cni_node_cidr = false
$cni_network_provider = undef
$install_dashboard = false
$taint_master = true
$node_label = $::hostname
$cluster_service_cidr = undef
$kube_api_service_ip = undef
$kube_dns_ip = undef

}
