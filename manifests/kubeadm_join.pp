# == kubernetes::kubeadm_join
define kubernetes::kubeadm_join (
  String $node_name                        = $kubernetes::node_name,
  String $kubernetes_version               = $kubernetes::kubernetes_version,
  String $config                           = $kubernetes::config_file,
  String $controller_address               = $kubernetes::controller_address,
  String $ca_cert_hash                     = $kubernetes::discovery_token_hash,
  String $discovery_token                  = $kubernetes::token,
  String $tls_bootstrap_token              = $kubernetes::token,
  String $token                            = $kubernetes::token,
  Optional[String] $feature_gates          = undef,
  Optional[String] $cri_socket             = undef,
  Optional[String] $discovery_file         = undef,
  Optional[Array] $env                     = $kubernetes::environment,
  Optional[Array] $ignore_preflight_errors = undef,
  Array $path                              = $kubernetes::default_path,
  Boolean $skip_ca_verification            = false,
) {

  case $kubernetes_version {
    # K1.11 and below don't use the config file
    /^1.1(0|1)/: {
      $kubeadm_join_flags = kubeadm_join_flags({
        controller_address       => $controller_address,
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
    }
    default: {
      $kubeadm_join_flags = kubeadm_join_flags({
        config                   => $config,
        discovery_file           => $discovery_file,
        feature_gates            => $feature_gates,
        ignore_preflight_errors  => $ignore_preflight_errors,
      })
    }
  }

  $exec_join = "kubeadm join ${kubeadm_join_flags}"
  $unless_join = "kubectl get nodes | grep ${node_name}"

  exec { 'kubeadm join':
    command     => $exec_join,
    environment => $env,
    path        => $path,
    logoutput   => true,
    timeout     => 0,
    unless      => $unless_join,
  }

}
