# This class configures the RBAC roles for Kubernetes 1.10.x

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
