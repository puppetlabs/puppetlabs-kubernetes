# == kubernetes::kubeadm_init
# @param node_name
#   Name of the node. Defaults to a fact
# @param config
#   Path to the configuration file. Defaults to '/etc/kubernetes/config.yaml'
# @param dry_run
#   Defaults to false
# @param path
#   The path to be used when running kube* commands. Defaults to ['/usr/bin','/bin','/sbin','/usr/local/bin']
# @param env
#   The environment passed to kubectl commands. Defaults to setting HOME and KUBECONFIG variables
# @param ignore_preflight_errors
#   Defaults to undef
# @param skip_phases
#   Allow kubeadm init skip some phases. Default: none phases skipped
#
define kubernetes::kubeadm_init (
  Stdlib::Fqdn $node_name                       = $kubernetes::node_name,
  Optional[String] $config                      = $kubernetes::config_file,
  Boolean $dry_run                              = false,
  Array $path                                   = $kubernetes::default_path,
  Optional[Array] $env                          = $kubernetes::environment,
  Optional[Array] $ignore_preflight_errors      = $kubernetes::ignore_preflight_errors,
  Optional[String] $skip_phases                 = $kubernetes::skip_phases,
) {
  $kubeadm_init_flags = kubeadm_init_flags({
      config                  => $config,
      dry_run                 => $dry_run,
      ignore_preflight_errors => $ignore_preflight_errors,
      skip_phases             => $skip_phases,
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
