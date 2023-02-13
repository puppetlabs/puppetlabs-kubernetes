# == kubernetes::kubeadm_join
# @param node_name
#   Name of the node. Defaults to a fact
# @param kubernetes_version
#   The version of Kubernetes containers you want to install.
#   ie api server,
#   Defaults to  1.10.2
# @param config
#   Path to the configuration file. Defaults to '/etc/kubernetes/config.yaml'
# @param controller_address
#   The IP address and Port of the controller that worker node will join. eg 172.17.10.101:6443
#   Defaults to undef
# @param ca_cert_hash
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
# @param discovery_token
#   A string to use when joining nodes to the cluster. Must be in the form of '[a-z0-9]{6}.[a-z0-9]{16}'
#   Defaults to undef
# @param tls_bootstrap_token
#   A string to use when joining nodes to the cluster. Must be in the form of '[a-z0-9]{6}.[a-z0-9]{16}'
#   Defaults to undef
# @param token
#   A string to use when joining nodes to the cluster. Must be in the form of '[a-z0-9]{6}.[a-z0-9]{16}'
#   Defaults to undef
# @param feature_gates
#   Defaults to undef
# @param cri_socket
#   Defaults to undef
# @param discovery_file
#   Defaults to undef
# @param env
#   The environment passed to kubectl commands. Defaults to setting HOME and KUBECONFIG variables
# @param ignore_preflight_errors
#   Defaults to undef
# @param path
#   The path to be used when running kube* commands. Defaults to ['/usr/bin','/bin','/sbin','/usr/local/bin']
# @param skip_ca_verification
#   Check to determine whether to skip the ca verification. Defaults to false
#
define kubernetes::kubeadm_join (
  Stdlib::Fqdn $node_name                  = $kubernetes::node_name,
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
          token                    => $token,
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

  exec { 'kubeadm join':
    command     => "kubeadm join ${kubeadm_join_flags}",
    environment => $env,
    path        => $path,
    logoutput   => true,
    timeout     => 0,
    unless      => "kubectl get nodes | grep ${node_name}",
  }
}
