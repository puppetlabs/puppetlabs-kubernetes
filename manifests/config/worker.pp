# Class kubernetes config_worker, populates worker config files with joinconfig
class kubernetes::config::worker (
  String $node_name                        = $kubernetes::node_name,
  String $config_file                      = $kubernetes::config_file,
  String $kubernetes_version               = $kubernetes::kubernetes_version,
  String $controller_address               = $kubernetes::controller_address,
  String $discovery_token_hash             = $kubernetes::discovery_token_hash,
  String $container_runtime                = $kubernetes::container_runtime,
  String $discovery_token                  = $kubernetes::token,
  String $tls_bootstrap_token              = $kubernetes::token,
  String $token                            = $kubernetes::token,
  Optional[String] $discovery_file         = undef,
  Optional[String] $feature_gates          = undef,
  Optional[String] $cloud_provider         = $kubernetes::cloud_provider,
  Optional[String] $cloud_config           = $kubernetes::cloud_config,
  Optional[Array] $kubelet_extra_arguments = $kubernetes::kubelet_extra_arguments,
  Optional[Hash] $kubelet_extra_config     = $kubernetes::kubelet_extra_config,
  Optional[Array] $ignore_preflight_errors = undef,
  Boolean $skip_ca_verification            = false,
) {
  # Need to merge the cloud configuration parameters into extra_arguments
  if !empty($cloud_provider) {
    $cloud_args = empty($cloud_config) ? {
      true    => ["cloud-provider: ${cloud_provider}"],
      default => ["cloud-provider: ${cloud_provider}", "cloud-config: ${cloud_config}"],
    }
    $kubelet_merged_extra_arguments = concat($kubelet_extra_arguments, $cloud_args)
  }
  else {
    $kubelet_merged_extra_arguments = $kubelet_extra_arguments
  }

  # to_yaml emits a complete YAML document, so we must remove the leading '---'
  $kubelet_extra_config_yaml = regsubst(to_yaml($kubelet_extra_config), '^---\n', '')

  $template = $kubernetes_version ? {
    default => 'v1alpha3',
  }

  file { $config_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("kubernetes/${template}/config_worker.yaml.erb"),
  }
}
