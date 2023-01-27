# == kubernetes::wait_for_default_sa
#
# @param namespace
#  Namespace name must be a valid DNS name (max. 63 characters)
#  see https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#namespaces-and-dns
#
define kubernetes::wait_for_default_sa (
  Kubernetes::Namespace $namespace = $title,
  Array $path                      = $kubernetes::default_path,
  Optional[Integer] $timeout       = undef,
  Optional[Integer] $tries         = $kubernetes::wait_for_default_sa_tries,
  Optional[Integer] $try_sleep     = $kubernetes::wait_for_default_sa_try_sleep,
  Optional[Array] $env             = $kubernetes::environment,
) {
  # This prevents a known race condition https://github.com/kubernetes/kubernetes/issues/66689
  exec { "wait for default serviceaccount creation in ${namespace}":
    command     => "kubectl -n ${namespace} get serviceaccount default -o name",
    unless      => "kubectl -n ${namespace} get serviceaccount default -o name",
    path        => $path,
    environment => $env,
    timeout     => $timeout,
    tries       => $tries,
    try_sleep   => $try_sleep,
  }
}
