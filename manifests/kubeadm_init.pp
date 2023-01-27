# == kubernetes::kubeadm_init
define kubernetes::kubeadm_init (
  Stdlib::Fqdn $node_name                       = $kubernetes::node_name,
  Optional[String] $config                      = $kubernetes::config_file,
  Boolean $dry_run                              = false,
  Boolean $kube_proxy_enable                    = $kubernetes::kube_proxy_enable,
  Array $path                                   = $kubernetes::default_path,
  Optional[Array] $env                          = $kubernetes::environment,
  Optional[Array] $ignore_preflight_errors      = $kubernetes::ignore_preflight_errors,
  Optional[String] $skip_phases                 = $kubernetes::skip_phases,
) {
  $skip_phases_merge = $kube_proxy_enable ? {
    true    => $skip_phases,
    default => "${skip_phases},addon/kube-proxy".regsubst(/^,/, ''),
  }

  $kubeadm_init_flags = kubeadm_init_flags({
      config                  => $config,
      dry_run                 => $dry_run,
      ignore_preflight_errors => $ignore_preflight_errors,
      skip_phases             => $skip_phases_merge,
  })

  exec { 'kubeadm init':
    command     => "kubeadm init ${kubeadm_init_flags}",
    environment => $env,
    path        => $path,
    logoutput   => true,
    timeout     => 0,
    unless      => "kubectl get nodes | grep ${node_name}",
  }

  # This prevents a known race condition https://github.com/kubernetes/kubernetes/issues/66689
  kubernetes::wait_for_default_sa { 'default': }
}
