# Class kubernetes config kubeadm, populates kubeadm config file with params to bootstrap cluster
# @param config_file
#   Path to the configuration file. Defaults to '/etc/kubernetes/config.yaml'
# @param controller_address
#   The IP address and Port of the controller that worker node will join. eg 172.17.10.101:6443
#   Defaults to undef
# @param dns_domain
#   This is a string that sets the dns domain in kubernetes cluster
#   Default cluster.local
# @param manage_etcd
#   When set to true, etcd will be downloaded from the specified source URL.
#   Defaults to true.
# @param delegated_pki
#   Set to true if all required X509 certificates will be provided by external means. Setting this to true will ignore all *_crt and *_key including sa.key and sa.pub files.
#   Defaults to false
# @param etcd_install_method
#   The method on how to install etcd. Can be either wget (using etcd_source) or package (using $etcd_package_name)
#   Defaults to wget
# @param kubernetes_version
#   The version of Kubernetes containers you want to install.
#   ie api server,
#   Defaults to  1.10.2
# @param kubernetes_cluster_name
#   The name of the cluster, for use when multiple clusters are accessed from the same source
#   Only used by Kubernetes 1.12+
#   Defaults to "kubernetes"
# @param etcd_ca_key
#   This is the ca certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcd_ca_crt
#   This is the ca certificate data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcdclient_key
#   This is the client certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcdclient_crt
#   This is the client certificate data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcdserver_crt
#   This is the server certificate data for the etcd cluster . This must be passed as string not as a file.
#   Defaults to undef
# @param etcdserver_key
#   This is the server certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcdpeer_crt
#   This is the peer certificate data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcdpeer_key
#   This is the peer certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
# @param etcd_peers
#   This will tell etcd how the list of peers to connect to into the cluster.
#   An example with hiera would be kubernetes::etcd_peers:
#       - 172.17.10.101
#       - 172.17.10.102
#       - 172.17.10.103
#   Defaults to undef
# @param etcd_hostname
#   The name of the etcd instance.
#   An example with hiera would be kubernetes::etcd_hostname: "%{::fqdn}"
#   Defaults to hostname
# @param etcd_data_dir
#   Directory, where etcd data is stored.
#   Defaults to /var/lib/etcd.
# @param etcd_ip
#   The ip address that you want etcd to use for communications.
#   An example with hiera would be kubernetes::etcd_ip: "%{networking.ip}"
#   Or to pin explicitly to a specific interface kubernetes::etcd_ip: "%{::ipaddress_enp0s8}"
#   Defaults to undef
# @param cni_pod_cidr
#   The overlay (internal) network range to use.
#   Defaults to undef. kube_tool sets this per cni provider.
# @param kube_api_bind_port
#   Apiserver bind port
#   Defaults to 6443
# @param kube_api_advertise_address
#   This is the ip address that the want to api server to expose.
#   An example with hiera would be kubernetes::kube_api_advertise_address: "%{networking.ip}"
#   Or to pin explicitly to a specific interface kubernetes::kube_api_advertise_address: "%{::ipaddress_enp0s8}"
#   defaults to undef
# @param etcd_initial_cluster
#   This will tell etcd how many nodes will be in the cluster and is passed as a string.
#   An example with hiera would be kubernetes::etcd_initial_cluster: etcd-kube-control-plane=http://172.17.10.101:2380,etcd-kube-replica-control-plane-01=http://172.17.10.210:2380,etcd-kube-replica-control-plane-02=http://172.17.10.220:2380
#   Defaults to undef
# @param etcd_discovery_srv
#   This will tell etcd to use DNS SRV discovery method. This option is exclusive with `etcd_initial_cluster`, taking precedence
#   over it if both are present.
#   An example with hiera would be kubernetes::etcd_discovery_srv: etcd-gen.example.org
#   Defaults to undef
# @param etcd_initial_cluster_state
#   This will tell etcd the initial state of the cluster. Useful for adding a node to the cluster. Allowed values are
#   "new" or "existing"
#   Defaults to "new"
# @param etcd_compaction_method
#   This will tell etcd the compaction method to be used.
#   "periodic" or "revision"
#   Defaults to "periodic"
# @param etcd_compaction_retention
#   This will tell etcd how much retention to be applied. This value can change depending on `etcd_compaction_method`. An integer or time string (i.e.: "5m") can be used in case of "periodic". Only integer allowed in case of "revision"
#   Integer or String
#   Defaults to 0 (disabled)
# @param api_server_count
#   Defaults to undef
# @param etcd_version
#   The version of etcd that you would like to use.
#   Defaults to 3.2.18
# @param etcd_max_wals
#   This will tell etcd how many WAL files to be kept
#   Defaults to 5
# @param etcd_max_request_bytes
#   This will tell etcd the maximum size of a request in bytes
#   Defaults to 1572864
# @param etcd_listen_metric_urls
#   The URL(s) to listen on to respond to /metrics and /health for etcd
#   Defaults to undef
# @param token
#   A string to use when joining nodes to the cluster. Must be in the form of '[a-z0-9]{6}.[a-z0-9]{16}'
#   Defaults to undef
# @param ttl_duration
#   Availability of the token
#   Default to 24h
# @param discovery_token_hash
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
# @param kubernetes_ca_crt
#   The clusters ca certificate. Must be passed as a string not a file.
#   Defaults to undef
# @param kubernetes_ca_key
#   The clusters ca key. Must be passed as a string not a file.
#   Defaults to undef
# @param kubernetes_front_proxy_ca_crt
#   The clusters front-proxy ca certificate. Must be passed as a string not a file.
#   Defaults to undef
# @param kubernetes_front_proxy_ca_key
#   The clusters front-proxy ca key. Must be passed as a string not a file.
#   Defaults to undef
# @param container_runtime
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker"
#   Defaults to cri_containerd
# @param sa_pub
#   The service account public key. Must be passed as cert not a file.
#   Defaults to undef
# @param sa_key
#   The service account key. Must be passed as string not a file.
#   Defaults to undef
# @param apiserver_cert_extra_sans
#   A string array of Subhect Alternative Names for the api server certificates.
#   Defaults to []
# @param apiserver_extra_arguments
#   A string array of extra arguments to be passed to the api server.
#   Defaults to []
# @param controllermanager_extra_arguments
#   A string array of extra arguments to be passed to the controller manager.
#   Defaults to []
# @param scheduler_extra_arguments
#   A string array of extra arguments to be passed to scheduler.
#   Defaults to []
# @param kubelet_extra_arguments
#   A string array to be appended to kubeletExtraArgs in the Kubelet's nodeRegistration configuration applied to both control planes and nodes.
#   Use this for critical Kubelet settings such as `pod-infra-container-image` which may be problematic to configure via kubelet_extra_config
#   Defaults to []
# @param service_cidr
#   The IP assdress range for service VIPs
#   Defaults to 10.96.0.0/12
# @param node_name
#   Name of the node. Defaults to a fact
# @param cloud_provider
#   The name of the cloud provider of the cloud provider configured in /etc/kubernetes/cloud-config
#   Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#   Defaults to undef
# @param cloud_config
#   The file location of the cloud config to be used by cloud_provider [*For use with v1.12 and above*]
#   Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#   Defaults to undef
# @param apiserver_extra_volumes
#   A hash of extra volume mounts mounted on the api server.
#   Defaults to {}
# @param controllermanager_extra_volumes
#   A hash of extra volume mounts mounted on the controller manager.
#   Defaults to []
# @param kubeadm_extra_config
#   A hash containing extra configuration data to be serialised with `to_yaml` and appended to the config.yaml file used by kubeadm.
#   Defaults to {}
# @param kubelet_extra_config
#   A hash containing extra configuration data to be serialised with `to_yaml` and appended to Kubelet configuration file for the cluster.
#   Requires DynamicKubeletConfig.
#   Defaults to {}
# @param image_repository
#   The container registry to pull control plane images from
#   Defaults to k8s.gcr.io
# @param cgroup_driver
#   The cgroup driver to be used.
#   Defaults to 'systemd'
# @param proxy_mode
#   The mode for kubeproxy to run. It should be one of: "" (default), "userspace", "kernelspace", "iptables", or "ipvs".
#   Defaults to ""
# @param metrics_bind_address
#   Set the metricsBindAddress (to allow prometheus)
#   Default to 127.0.0.1
# @param conntrack_max_per_core
#   Maximum number of NAT connections to track per CPU core.
#   Set to 0 to leave the limit as-is and ignore conntrack_min.
#   Default to 32768
# @param conntrack_min
#   Minimum number of conntrack entries to allocate, regardless of conntrack-max-per-core.
#   Set conntrack_max_per_core to 0 to leave the limit as-is
#   Default to 131072
# @param conntrack_tcp_wait_timeout
#   NAT timeout for TCP connections in the CLOSE_WAIT state.
#   Default to 1h0m0s
# @param conntrack_tcp_stablished_timeout
#   Idle timeout for established TCP connections (0 to leave as-is).
#   Default to 24h0m0s
# @param feature_gates
#  Feature gate hash to be added to kubeadm configuration
#  Example:
#   {'RootlessControlPlane' => true}
#   Default: undefined, no feature gates
#
class kubernetes::config::kubeadm (
  String $config_file = $kubernetes::config_file,
  String $controller_address = $kubernetes::controller_address,
  String $dns_domain = $kubernetes::dns_domain,
  Boolean $manage_etcd = $kubernetes::manage_etcd,
  Boolean $delegated_pki = $kubernetes::delegated_pki,
  String $etcd_install_method = $kubernetes::etcd_install_method,
  String $kubernetes_version  = $kubernetes::kubernetes_version,
  String $kubernetes_cluster_name  = $kubernetes::kubernetes_cluster_name,
  Optional[String] $etcd_ca_key = $kubernetes::etcd_ca_key,
  Optional[String] $etcd_ca_crt = $kubernetes::etcd_ca_crt,
  Optional[String] $etcdclient_key = $kubernetes::etcdclient_key,
  Optional[String] $etcdclient_crt = $kubernetes::etcdclient_crt,
  Optional[String] $etcdserver_crt = $kubernetes::etcdserver_crt,
  Optional[String] $etcdserver_key = $kubernetes::etcdserver_key,
  Optional[String] $etcdpeer_crt = $kubernetes::etcdpeer_crt,
  Optional[String] $etcdpeer_key = $kubernetes::etcdpeer_key,
  Array $etcd_peers = $kubernetes::etcd_peers,
  String $etcd_hostname = $kubernetes::etcd_hostname,
  String $etcd_data_dir = $kubernetes::etcd_data_dir,
  String $etcd_ip = $kubernetes::etcd_ip,
  String $cni_pod_cidr = $kubernetes::cni_pod_cidr,
  Integer $kube_api_bind_port = $kubernetes::kube_api_bind_port,
  String $kube_api_advertise_address = $kubernetes::kube_api_advertise_address,
  Optional[String] $etcd_initial_cluster = $kubernetes::etcd_initial_cluster,
  Optional[String] $etcd_discovery_srv = $kubernetes::etcd_discovery_srv,
  String $etcd_initial_cluster_state = $kubernetes::etcd_initial_cluster_state,
  String $etcd_compaction_method = $kubernetes::etcd_compaction_method,
  Variant[Integer,String] $etcd_compaction_retention = $kubernetes::etcd_compaction_retention,
  Integer $api_server_count = $kubernetes::api_server_count,
  String $etcd_version = $kubernetes::etcd_version,
  Integer $etcd_max_wals = $kubernetes::etcd_max_wals,
  Integer $etcd_max_request_bytes = $kubernetes::etcd_max_request_bytes,
  Optional[String] $etcd_listen_metric_urls = $kubernetes::etcd_listen_metric_urls,
  String $token = $kubernetes::token,
  String $ttl_duration = $kubernetes::ttl_duration,
  String $discovery_token_hash = $kubernetes::discovery_token_hash,
  Optional[String] $kubernetes_ca_crt = $kubernetes::kubernetes_ca_crt,
  Optional[String] $kubernetes_ca_key = $kubernetes::kubernetes_ca_key,
  Optional[String] $kubernetes_front_proxy_ca_crt = $kubernetes::kubernetes_front_proxy_ca_crt,
  Optional[String] $kubernetes_front_proxy_ca_key = $kubernetes::kubernetes_front_proxy_ca_key,
  String $container_runtime = $kubernetes::container_runtime,
  Optional[String] $sa_pub = $kubernetes::sa_pub,
  Optional[String] $sa_key = $kubernetes::sa_key,
  Optional[Array] $apiserver_cert_extra_sans = $kubernetes::apiserver_cert_extra_sans,
  Optional[Array] $apiserver_extra_arguments = $kubernetes::apiserver_extra_arguments,
  Optional[Array] $controllermanager_extra_arguments = $kubernetes::controllermanager_extra_arguments,
  Optional[Array] $scheduler_extra_arguments = $kubernetes::scheduler_extra_arguments,
  Optional[Array] $kubelet_extra_arguments = $kubernetes::kubelet_extra_arguments,
  String $service_cidr = $kubernetes::service_cidr,
  Stdlib::Fqdn $node_name = $kubernetes::node_name,
  Optional[String] $cloud_provider = $kubernetes::cloud_provider,
  Optional[String] $cloud_config = $kubernetes::cloud_config,
  Optional[Hash] $apiserver_extra_volumes = $kubernetes::apiserver_extra_volumes,
  Optional[Hash] $controllermanager_extra_volumes = $kubernetes::controllermanager_extra_volumes,
  Optional[Hash] $kubeadm_extra_config = $kubernetes::kubeadm_extra_config,
  Optional[Hash] $kubelet_extra_config = $kubernetes::kubelet_extra_config,
  String $image_repository = $kubernetes::image_repository,
  String $cgroup_driver = $kubernetes::cgroup_driver,
  String $proxy_mode = $kubernetes::proxy_mode,
  Stdlib::IP::Address $metrics_bind_address = $kubernetes::metrics_bind_address,
  Integer $conntrack_max_per_core = $kubernetes::conntrack_max_per_core,
  Integer $conntrack_min = $kubernetes::conntrack_min,
  String $conntrack_tcp_wait_timeout = $kubernetes::conntrack_tcp_wait_timeout,
  String $conntrack_tcp_stablished_timeout = $kubernetes::conntrack_tcp_stablished_timeout,
  Hash[String[1], Boolean] $feature_gates = $kubernetes::feature_gates,
) {
  if !($proxy_mode in ['', 'userspace', 'iptables', 'ipvs', 'kernelspace']) {
    fail('Invalid kube-proxy mode! Must be one of "", userspace, iptables, ipvs, kernelspace.')
  }

  if !($etcd_discovery_srv or $etcd_initial_cluster) {
    fail('One of $etcd_discovery_srv or $etcd_initial_cluster variables must be defined')
  }

  $kube_dirs = ['/etc/kubernetes','/etc/kubernetes/manifests','/etc/kubernetes/pki','/etc/kubernetes/pki/etcd']
  $etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
  $pki = ['ca.crt','ca.key','front-proxy-ca.crt','front-proxy-ca.key','sa.pub','sa.key']
  $kube_dirs.each | String $dir | {
    file { $dir :
      ensure  => directory,
      mode    => '0600',
      recurse => true,
    }
  }

  if $manage_etcd {
    if !$delegated_pki {
      $etcd.each | String $etcd_files | {
        file { "/etc/kubernetes/pki/etcd/${etcd_files}":
          ensure  => file,
          content => template("kubernetes/etcd/${etcd_files}.erb"),
          mode    => '0600',
        }
      }
    }
    if $etcd_install_method == 'wget' {
      file { '/etc/systemd/system/etcd.service':
        ensure  => file,
        content => template('kubernetes/etcd/etcd.service.erb'),
      }
    } else {
      file { '/etc/default/etcd':
        ensure  => file,
        content => template('kubernetes/etcd/etcd.erb'),
      }
    }
  }

  if !$delegated_pki {
    $pki.each | String $pki_files | {
      file { "/etc/kubernetes/pki/${pki_files}":
        ensure  => file,
        content => template("kubernetes/pki/${pki_files}.erb"),
        mode    => '0600',
      }
    }
  }

  # The alpha1 schema puts Kubelet configuration in a different place.
  $kubelet_extra_config_alpha1 = {
    'kubeletConfiguration' => {
      'baseConfig' => $kubelet_extra_config,
    },
  }

  # Need to merge the cloud configuration parameters into extra_arguments
  if $cloud_provider {
    $cloud_args = $cloud_config ? {
      undef   => ["cloud-provider: ${cloud_provider}"],
      default => ["cloud-provider: ${cloud_provider}", "cloud-config: ${cloud_config}"],
    }
    $apiserver_merged_extra_arguments = concat($apiserver_extra_arguments, $cloud_args)
    $controllermanager_merged_extra_arguments = concat($controllermanager_extra_arguments, $cloud_args)

    # could check against Kubernetes 1.10 here, but that uses alpha1 config which doesn't have these options
    if $cloud_config {
      # The cloud config must be mounted into the apiserver and controllermanager containers
      $cloud_volume = {
        'cloud' => {
          hostPath  => $cloud_config,
          mountPath => $cloud_config,
        },
      }
      if 'cloud' in $apiserver_extra_volumes or 'cloud' in $controllermanager_extra_volumes {
        fail('Cannot use "cloud" as volume name')
      }

      $apiserver_merged_extra_volumes = stdlib::merge($apiserver_extra_volumes, $cloud_volume)
      $controllermanager_merged_extra_volumes = stdlib::merge($controllermanager_extra_volumes, $cloud_volume)
    } else {
      $apiserver_merged_extra_volumes = $apiserver_extra_volumes
      $controllermanager_merged_extra_volumes = $controllermanager_extra_volumes
    }
  } else {
    $apiserver_merged_extra_arguments = $apiserver_extra_arguments
    $controllermanager_merged_extra_arguments = $controllermanager_extra_arguments

    $apiserver_merged_extra_volumes = $apiserver_extra_volumes
    $controllermanager_merged_extra_volumes = $controllermanager_extra_volumes
  }

  # to_yaml emits a complete YAML document, so we must remove the leading '---'
  $kubeadm_extra_config_yaml = regsubst(stdlib::to_yaml($kubeadm_extra_config), '^---\n', '')
  $kubelet_extra_config_yaml = regsubst(stdlib::to_yaml($kubelet_extra_config), '^---\n', '')
  $kubelet_extra_config_alpha1_yaml = regsubst(stdlib::to_yaml($kubelet_extra_config_alpha1), '^---\n', '')

  $config_version = $kubernetes_version ? {
    /^1\.1(0|1)/              => 'v1alpha1',
    /^1\.12/                  => 'v1alpha3',
    /^1\.1(3|4|5\.[012])/     => 'v1beta1',
    /^1\.(16|17|18|19|20|21)/ => 'v1beta2',
    default                  => 'v1beta3',
  }

  # master role is DEPRECATED
  if versioncmp($kubernetes_version, '1.20.0') >= 0 {
    $node_role = 'control-plane'
  } else {
    $node_role = 'master'
  }

  file { $config_file:
    ensure  => file,
    content => template("kubernetes/${config_version}/config_kubeadm.yaml.erb"),
    mode    => '0600',
  }
}
