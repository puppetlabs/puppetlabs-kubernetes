# Class kubernetes config_worker, populates worker config files with joinconfig
class kubernetes::config::worker (
  String $node_name                        = $kubernetes::node_name,
  String $config_file                      = $kubernetes::config_file,
  String $kubernetes_version               = $kubernetes::kubernetes_version,
  String $kubernetes_cluster_name          = $kubernetes::kubernetes_cluster_name,
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
  String $cgroup_driver                    = $kubernetes::cgroup_driver,
  Optional[Array] $skip_phases_join        = $kubernetes::skip_phases_join,
  Optional[String] $node_role              = $kubernetes::node_role,
) {
  # to_yaml emits a complete YAML document, so we must remove the leading '---'
  $kubelet_extra_config_yaml = regsubst(to_yaml($kubelet_extra_config), '^---\n', '')

  $template = $kubernetes_version ? {
    /1\.12/                  => 'v1alpha3',
    /1\.1(3|4|5\.[012])/     => 'v1beta1',
    /1\.(16|17|18|19|20|21)/ => 'v1beta2',
    default                  => 'v1beta3',
  }

  file { '/etc/kubernetes':
    ensure  => directory,
    mode    => '0600',
    recurse => true,
  }

  file { $config_file:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    content   => template("kubernetes/${template}/config_worker.yaml.erb"),
    show_diff => false,
  }
}
