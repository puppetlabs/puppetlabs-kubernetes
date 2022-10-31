# == kubernetes::wait_for_default_sa
define kubernetes::wait_for_default_sa (
  String $namespace            = $title,
  Array $path                  = $kubernetes::default_path,
  Optional[Integer] $timeout   = undef,
  Optional[Integer] $tries     = $kubernetes::wait_for_default_sa_tries,
  Optional[Integer] $try_sleep = $kubernetes::wait_for_default_sa_try_sleep,
  Optional[Array] $env         = $kubernetes::environment,
) {
  $safe_namespace = shell_escape($namespace)

  # This prevents a known race condition https://github.com/kubernetes/kubernetes/issues/66689
  exec { "wait for default serviceaccount creation in ${safe_namespace}":
    command     => "kubectl -n ${safe_namespace} get serviceaccount default -o name",
    unless      => "kubectl -n ${safe_namespace} get serviceaccount default -o name",
    path        => $path,
    environment => $env,
    timeout     => $timeout,
    tries       => $tries,
    try_sleep   => $try_sleep,
  }
}
