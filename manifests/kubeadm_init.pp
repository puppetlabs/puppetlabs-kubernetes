# == kubernetes::kubeadm_init
define kubernetes::kubeadm_init (
  String $node_label                            = $node_label,
  Optional[String] $apiserver_advertise_address = undef,
  Optional[Integer] $apiserver_bind_port        = undef,
  Optional[Array] $apiserver_cert_extra_sans    = undef,
  Optional[String] $cert_dir                    = undef,
  Optional[String] $config                      = undef,
  Optional[String] $cri_socket                  = undef,
  Boolean $dry_run                              = false,
  Optional[Array] $env                          = undef,
  Optional[Array] $feature_gates                = undef,
  Optional[Array] $ignore_preflight_errors      = undef,
  Optional[String] $kubernetes_version          = undef,
  Optional[String] $node_name                   = undef,
  Optional[String] $pod_network_cidr            = undef,
  Optional[String] $service_cidr                = undef,
  Optional[String] $service_dns_domain          = undef,
  Optional[Array] $path                         = undef,
  Boolean $skip_token_print                     = false,
  Optional[String] $token                       = undef,
  Optional[String] $token_ttl                   = undef,
) {

  $kubeadm_init_flags = kubeadm_init_flags({
    apiserver_advertise_address => $apiserver_advertise_address,
    apiserver_bind_port         => $apiserver_bind_port,
    apiserver_cert_extra_sans   => $apiserver_cert_extra_sans,
    cert_dir                    => $cert_dir,
    config                      => $config,
    cri_socket                  => $cri_socket,
    dry_run                     => $dry_run,
    feature_gates               => $feature_gates,
    ignore_preflight_errors     => $ignore_preflight_errors,
    kubernetes_version          => $kubernetes_version,
    node_name                   => $node_name,
    pod_network_cidr            => $pod_network_cidr,
    service_cidr                => $service_cidr,
    service_dns_domain          => $service_dns_domain,
    skip_token_print            => $skip_token_print,
    token_ttl                   => $token_ttl,
    token                       => $token,
  })


  $exec_init = "kubeadm init ${kubeadm_init_flags}"
  $unless_init = "kubectl get nodes | grep ${node_label}"

  exec { 'kubeadm init':
    command     => $exec_init,
    environment => $env,
    path        => $path,
    logoutput   => true,
    timeout     => 0,
    unless      => $unless_init,
  }

}
