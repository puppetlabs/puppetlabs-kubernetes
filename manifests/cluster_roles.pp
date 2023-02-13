# @summary
#   This class configures the RBAC roles for Kubernetes 1.10.x
#
# @param controller
#   This is a bool that sets the node as a Kubernetes controller. Defaults to false.
# @param worker
#   This is a bool that sets a node to a worker. Defaults to false.
# @param node_name
#   Sets the name of the node. Defaults to a networking fact.
# @param container_runtime
#   Configure whether the container runtime should be configured to use a proxy.
#   If set to true, the container runtime will use the http_proxy, https_proxy and no_proxy values.
#   Defaults to false
# @param join_discovery_file
#   Sets the name of the discovery file. Defaults to undef.
# @param ignore_preflight_errors
#   List of errors to ignore pre_flight. Defaults to undef.
# @param env
#   The environment passed to kubectl commands.
#   Defaults to setting HOME and KUBECONFIG variables
# @param skip_phases
#   Allow kubeadm init skip some phases
#   Default: none phases skipped
#
class kubernetes::cluster_roles (
  Optional[Boolean] $controller = $kubernetes::controller,
  Optional[Boolean] $worker = $kubernetes::worker,
  Stdlib::Fqdn $node_name = $kubernetes::node_name,
  String $container_runtime = $kubernetes::container_runtime,
  Optional[String] $join_discovery_file = $kubernetes::join_discovery_file,
  Optional[Array] $ignore_preflight_errors = $kubernetes::ignore_preflight_errors,
  Optional[Array] $env = $kubernetes::environment,
  Optional[String] $skip_phases = $kubernetes::skip_phases,
) {
  if $container_runtime == 'cri_containerd' {
    $preflight_errors = flatten(['Service-Docker',$ignore_preflight_errors])
    $cri_socket = '/run/containerd/containerd.sock'
  } else {
    $preflight_errors = $ignore_preflight_errors
    $cri_socket = undef
  }

  if $controller {
    kubernetes::kubeadm_init { $node_name:
      ignore_preflight_errors => $preflight_errors,
      env                     => $env,
      skip_phases             => $skip_phases,
    }
  }

  if $worker {
    kubernetes::kubeadm_join { $node_name:
      cri_socket              => $cri_socket,
      ignore_preflight_errors => $preflight_errors,
      discovery_file          => $join_discovery_file,
      env                     => $env,
    }
  }
}
