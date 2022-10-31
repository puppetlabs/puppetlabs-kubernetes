# == kubernetes::kubeadm_init
define kubernetes::kubeadm_init (
  String $node_name                             = $kubernetes::node_name,
  Boolean $kube_proxy_enable                    = $kubernetes::kube_proxy_enable,
  Optional[String] $config                      = $kubernetes::config_file,
  Boolean $dry_run                              = false,
  Array $path                                   = $kubernetes::default_path,
  Optional[Array] $env                          = $kubernetes::environment,
  Optional[Array] $ignore_preflight_errors      = $kubernetes::ignore_preflight_errors,
  Optional[String] $skip_phases                 = $kubernetes::skip_phases,
) {
  if !$kube_proxy_enable {
    if $skip_phases {
      $skip_phases_merge = "${skip_phases},addon/kube-proxy"
    }
    else {
      $skip_phases_merge = 'addon/kube-proxy'
    }
  }

  $kubeadm_init_flags = kubeadm_init_flags({
      config                  => $config,
      dry_run                 => $dry_run,
      ignore_preflight_errors => $ignore_preflight_errors,
      skip_phases             => $skip_phases_merge,
  })

  $exec_init = "kubeadm init ${kubeadm_init_flags}"
  $unless_init = "kubectl get nodes | grep ${node_name}"

  exec { 'kubeadm init':
    command     => $exec_init,
    environment => $env,
    path        => $path,
    logoutput   => true,
    timeout     => 0,
    unless      => $unless_init,
  }

  # This prevents a known race condition https://github.com/kubernetes/kubernetes/issues/66689
  kubernetes::wait_for_default_sa { 'default': }
}
