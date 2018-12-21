# == kubernetes::kubeadm_init
define kubernetes::kubeadm_init (
  String $node_name                             = $kubernetes::node_name,
  Optional[String] $config                      = $kubernetes::config_file,
  Boolean $dry_run                              = false,
  Optional[Array] $env                          = undef,
  Optional[Array] $path                         = undef,
  Optional[Array] $ignore_preflight_errors      = undef,
) {
  $kubeadm_init_flags = kubeadm_init_flags({
    config                  => $config,
    dry_run                 => $dry_run,
    ignore_preflight_errors => $ignore_preflight_errors,
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

}
