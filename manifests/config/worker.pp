# Class kubernetes config_worker, populates worker config files with joinconfig
# @param node_name
#   Name of the node. Defaults to a fact
# @param config_file
#   Path to the configuration file. Defaults to '/etc/kubernetes/config.yaml'
# @param kubernetes_version
#   The version of Kubernetes containers you want to install.
#   ie api server,
#   Defaults to  1.10.2
# @param kubernetes_cluster_name
#   The name of the cluster, for use when multiple clusters are accessed from the same source
#   Only used by Kubernetes 1.12+
#   Defaults to "kubernetes"
# @param controller_address
#   The IP address and Port of the controller that worker node will join. eg 172.17.10.101:6443
#   Defaults to undef
# @param discovery_token_hash
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
# @param container_runtime
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker"
#   Defaults to cri_containerd
# @param discovery_token
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
# @param tls_bootstrap_token
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
# @param token
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
# @param discovery_file
#   Defaults to undef
# @param feature_gates
#   Defaults to undef
# @param cloud_provider
#   The name of the cloud provider of the cloud provider configured in /etc/kubernetes/cloud-config
#   Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#   Defaults to undef
# @param cloud_config
#   The file location of the cloud config to be used by cloud_provider [*For use with v1.12 and above*]
#   Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#   Defaults to undef
# @param node_extra_taints
#   Additional taints for node.
#   Example:
#     [{'key' => 'dedicated','value' => 'NewNode','effect' => 'NoSchedule', 'operator' => 'Equal'}]
#   Defaults to undef
# @param kubelet_extra_arguments
#   A string array to be appended to kubeletExtraArgs in the Kubelet's nodeRegistration configuration applied to both control planes and nodes.
#   Use this for critical Kubelet settings such as `pod-infra-container-image` which may be problematic to configure via kubelet_extra_config
#   Defaults to []
# @param kubelet_extra_config
#   A hash containing extra configuration data to be serialised with `to_yaml` and appended to Kubelet configuration file for the cluster.
#   Requires DynamicKubeletConfig.
#   Defaults to {}
# @param ignore_preflight_errors
#   Defaults to undef
# @param skip_ca_verification
#   Defaults to false
# @param cgroup_driver
#   The cgroup driver to be used.
#   Defaults to 'systemd'
# @param skip_phases_join
#   Allow kubeadm join to skip some phases
#   Only works with Kubernetes 1.22+
#   Default: no phases skipped
#
class kubernetes::config::worker (
  Stdlib::Fqdn $node_name                  = $kubernetes::node_name,
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
  Optional[Array[Hash]] $node_extra_taints = $kubernetes::node_extra_taints,
  Optional[Array] $kubelet_extra_arguments = $kubernetes::kubelet_extra_arguments,
  Optional[Hash] $kubelet_extra_config     = $kubernetes::kubelet_extra_config,
  Optional[Array] $ignore_preflight_errors = undef,
  Boolean $skip_ca_verification            = false,
  String $cgroup_driver                    = $kubernetes::cgroup_driver,
  Optional[Array] $skip_phases_join        = $kubernetes::skip_phases_join,
) {
  # to_yaml emits a complete YAML document, so we must remove the leading '---'
  $kubelet_extra_config_yaml = regsubst(stdlib::to_yaml($kubelet_extra_config), '^---\n', '')

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
