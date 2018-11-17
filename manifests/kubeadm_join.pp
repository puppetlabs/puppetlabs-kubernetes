# == kubernetes::kubeadm_join
define kubernetes::kubeadm_join (
String $node_label                       = $node_label,
String $controller_address               = undef,
Optional[String] $ca_cert_hash           = undef,
Optional[String] $config                 = undef,
Optional[String] $cri_socket             = undef,
Optional[String] $discovery_file         = undef,
Optional[String] $discovery_token        = undef,
Optional[Array] $env                     = undef,
Optional[String] $feature_gates          = undef,
Optional[Array] $ignore_preflight_errors = undef,
Optional[String] $node_name              = undef,
Optional[Array] $path                    = undef,
Boolean $skip_ca_verification            = false,
Optional[String] $tls_bootstrap_token    = undef,
Optional[String] $token                  = undef
) {

  $kubeadm_join_flags = kubeadm_join_flags({
    controller_address       => $controller_address,
    config                   => $config,
    cri_socket               => $cri_socket,
    discovery_file           => $discovery_file,
    discovery_token          => $discovery_token,
    ca_cert_hash             => $ca_cert_hash,
    skip_ca_verification     => $skip_ca_verification,
    feature_gates            => $feature_gates,
    ignore_preflight_errors  => $ignore_preflight_errors,
    node_name                => $node_name,
    tls_bootstrap_token      => $tls_bootstrap_token,
    token                    => $token
  })


  $exec_join = "kubeadm join ${kubeadm_join_flags}"
  $unless_join = "kubectl get nodes | grep ${node_label}"

  exec { 'kubeadm join':
    command     => $exec_join,
    environment => $env,
    path        => $path,
    logoutput   => true,
    timeout     => 0,
    unless      => $unless_join,
  }

}
