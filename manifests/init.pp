# Class: kubernetes
# ===========================
#
# A module to build a Kubernetes cluster https://kubernetes.io/
#
# Parameters
# ----------
# [*kubernetes_version*]
#   The version of Kubernetes containers you want to install.
#   ie api server,
#   Defaults to  1.10.2
#
# [*kubernetes_cluster_name*]
#   The name of the cluster, for use when multiple clusters are accessed from the same source
#   Only used by Kubernetes 1.12+
#   Defaults to "kubernetes"
#
# [*kubernetes_package_version*]
#   The version of the packages the Kubernetes os packages to install
#   ie kubectl and kubelet
#   Defaults to 1.10.2
#
# [*container_runtime*]
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker"
#   Defaults to docker
#
# [*containerd_version*]
#   This is the version of the containerd runtime the module will install.
#   Defaults to 1.1.0
#
# [*containerd_install_method*]
#   Whether to install containerd via archive or package.
#   Defaults to archive
#
# [*containerd_package_name*]
#   containerd package name
#   Defaults to containerd.io
#
# [*containerd_archive*]
#  The name of the containerd archive
#  Defaults to containerd-${containerd_version}.linux-amd64.tar.gz
#
# [*containerd_archive_checksum*]
# A checksum (sha-256) of the archive. If the checksum does not match, a reinstall will be executed and the related service will be
# restarted. If no checksum is defined, the puppet module checks for the extracted files of the archive and downloads and extracts
# the files if they do not exist.
#
# [*containerd_source*]
#  The URL to download the containerd archive
#  Defaults to https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}
#
# [*containerd_config_template*]
#   The template to use for containerd configuration
#   This value is ignored if containerd_config_source is defined
#   Default to 'kubernetes/containerd/config.toml.epp'
#
# [*containerd_config_source*]
#   The source of the containerd configuration
#   This value overrides containerd_config_template
#   Default to undef
#
# [*containerd_socket*]
#   The path to containerd GRPC socket
#   Defaults to /run/containerd/containerd.sock
#
# [*containerd_plugins_registry*]
#  The configuration for the image registries used by containerd when containerd_install_method is package.
#  See https://github.com/containerd/containerd/blob/master/docs/cri/registry.md
#  Defaults to `undef`
#
# [*containerd_default_runtime_name*]
#   The default runtime to use with containerd
#   Defaults to runc
#
# [*containerd_sandbox_image*]
#  The configuration for the image pause container
#  Defaults registry.k8s.io/pause:3.2
#
# [*dns_domain*]
#   This is a string that sets the dns domain in kubernetes cluster
#   Default cluster.local
#
# [*docker_version*]
#   This is the version of the docker runtime that you want to install.
#   Defaults to 17.03.0.ce-1.el7.centos on RedHat
#   Defaults to 5:20.10.11~3-0~ubuntu-(distro codename) on Ubuntu
#
# [*docker_package_name*]
#  The docker package name to download from an upstream repo
#  Defaults to docker-engine
#
# [*cni_pod_cidr*]
#   The overlay (internal) network range to use.
#   Defaults to undef. kube_tool sets this per cni provider.
#
# [*cni_network_preinstall*]
#
#  The URL to install the Tigera operator.
#  Used only by calico.
#
# [*cni_network_provider*]
#
#  The URL to get the cni providers yaml file.
#  Defaults to `undef`. `kube_tool` sets this value.
#
# [*cni_provider*]
#
#  The NAME of the CNI provider, as provided to kubetool.
#
# [*cni_rbac_binding*]
#  The URL get the cni providers rbac rules. This is for use with Calico only.
#  Defaults to `undef`.
#
# [*controller*]
#   This is a bool that sets the node as a Kubernetes controller
#   Defaults to false
#
# [*worker*]
#   This is a bool that sets a node to a worker.
#   defaults to false
#
# [*manage_docker*]
#   Whether or not to install Docker repositories and packages via this module.
#   Defaults to true.
#
# [*manage_etcd*]
#   When set to true, etcd will be downloaded from the specified source URL.
#   Defaults to true.
#
# [*kube_api_advertise_address*]
#   This is the ip address that the want to api server to expose.
#   An example with hiera would be kubernetes::kube_api_advertise_address: "%{networking.ip}"
#   Or to pin explicitly to a specific interface kubernetes::kube_api_advertise_address: "%{::ipaddress_enp0s8}"
#   defaults to undef
#
# [*kube_api_bind_port*]
#   Apiserver bind port
#   Defaults to 6443
#
# [*etcd_version*]
#   The version of etcd that you would like to use.
#   Defaults to 3.2.18
#
# [*etcd_archive*]
#  The name of the etcd archive
#  Defaults to etcd-v${etcd_version}-linux-amd64.tar.gz
#
# [*etcd_archive_checksum*]
# A checksum (sha-256) of the archive. If the checksum does not match, a reinstall will be executed and the related service will be
# restarted. If no checksum is defined, the puppet module checks for the extracted files of the archive and downloads and extracts
# the files if they do not exist.
#
# [*etcd_source*]
#  The URL to download the etcd archive
#  Defaults to https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}
#
# [*etcd_install_method*]
#  The method on how to install etcd. Can be either wget (using etcd_source) or package (using $etcd_package_name)
#  Defaults to wget
#
# [*etcd_package_name*]
#  The system package name for installing etcd
#  Defaults to etcd-server
#
# [*runc_version*]
#  The version of runc to install
#  Defaults to 1.0.0
#
# [*runc_source*]
#  The URL to download runc
#  Defaults to https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64
#
# [*runc_source*_checksum*]
# A checksum (sha-256) of the archive. If the checksum does not match, a reinstall will be executed and the related service will be
# restarted. If no checksum is defined, the puppet module checks for the extracted files of the archive and downloads and extracts
# the files if they do not exist.
#
# [*etcd_hostname*]
#   The name of the etcd instance.
#   An example with hiera would be kubernetes::etcd_hostname: "%{::fqdn}"
#   Defaults to hostname
#
# [*etcd_data_dir*]
# Directory, where etcd data is stored.
# Defaults to /var/lib/etcd.
#
# [*etcd_ip*]
#   The ip address that you want etcd to use for communications.
#   An example with hiera would be kubernetes::etcd_ip: "%{networking.ip}"
#   Or to pin explicitly to a specific interface kubernetes::etcd_ip: "%{::ipaddress_enp0s8}"
#   Defaults to undef
#
# [*etcd_peers*]
#   This will tell etcd how the list of peers to connect to into the cluster.
#   An example with hiera would be kubernetes::etcd_peers:
#                                  - 172.17.10.101
#                                  - 172.17.10.102
#                                  - 172.17.10.103
#   Defaults to undef
#
# [*etcd_discovery_srv*]
#    This will tell etcd to use DNS SRV discovery method. This option is exclusive with `etcd_initial_cluster`, taking precedence
#    over it if both are present.
#   An example with hiera would be kubernetes::etcd_discovery_srv: etcd-gen.example.org
#   Defaults to undef
#
# [*etcd_initial_cluster*]
#    This will tell etcd how many nodes will be in the cluster and is passed as a string.
#   An example with hiera would be kubernetes::etcd_initial_cluster: etcd-kube-control-plane=http://172.17.10.101:2380,etcd-kube-replica-control-plane-01=http://172.17.10.210:2380,etcd-kube-replica-control-plane-02=http://172.17.10.220:2380
#   Defaults to undef
#
# [*etcd_initial_cluster_state*]
#     This will tell etcd the initial state of the cluster. Useful for adding a node to the cluster. Allowed values are
#   "new" or "existing"
#   Defaults to "new"
#
# [*etcd_compaction_retention*]
#     This will tell etcd how much retention to be applied. This value can change depending on `etcd_compaction_method`. An integer or time string (i.e.: "5m") can be used in case of "periodic". Only integer allowed in case of "revision"
#   Integer or String
#   Defaults to 0 (disabled)
#
# [*etcd_compaction_method*]
#     This will tell etcd the compaction method to be used.
#   "periodic" or "revision"
#   Defaults to "periodic"
#
# [*etcd_max_wals*]
#     This will tell etcd how many WAL files to be kept
#   Defaults to 5
#
# [*etcd_max_request_bytes*]
#     This will tell etcd the maximum size of a request in bytes
#   Defaults to 1572864
#
# [*etcd_listen_metric_urls*]
#     The URL(s) to listen on to respond to /metrics and /health for etcd
#   Defaults to undef
#
# [*etcd_ca_key*]
#   This is the ca certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcd_ca_crt*]
#   This is the ca certificate data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcdclient_key*]
#   This is the client certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcdclient_crt*]
#   This is the client certificate data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcdserver_key*]
#   This is the server certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcdserver_crt*]
#   This is the server certificate data for the etcd cluster . This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcdpeer_crt*]
#   This is the peer certificate data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*etcdpeer_key*]
#   This is the peer certificate key data for the etcd cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*apiserver_extra_arguments*]
#   A string array of extra arguments to be passed to the api server.
#   Defaults to []
#
# [*apiserver_cert_extra_sans*]
#   A string array of Subhect Alternative Names for the api server certificates.
#   Defaults to []
#
# [*apiserver_extra_volumes*]
#   A hash of extra volume mounts mounted on the api server.
#   Defaults to {}
#
# [*controllermanager_extra_arguments*]
#   A string array of extra arguments to be passed to the controller manager.
#   Defaults to []
#
# [*controllermanager_extra_volumes*]
#   A hash of extra volume mounts mounted on the controller manager.
#   Defaults to []
#
# [*scheduler_extra_arguments*]
#   A string array of extra arguments to be passed to scheduler.
#   Defaults to []
#
# [*delegated_pki*]
#   Set to true if all required X509 certificates will be provided by external means. Setting this to true will ignore all *_crt and *_key including sa.key and sa.pub files.
#   Defaults to false
#
# [*kubernetes_ca_crt*]
#   The clusters ca certificate. Must be passed as a string not a file.
#   Defaults to undef
#
# [*kubernetes_ca_key*]
#   The clusters ca key. Must be passed as a string not a file.
#   Defaults to undef
#
# [*kubernetes_front_proxy_ca_crt*]
#   The clusters front-proxy ca certificate. Must be passed as a string not a file.
#   Defaults to undef
#
# [*kubernetes_front_proxy_ca_key*]
#   The clusters front-proxy ca key. Must be passed as a string not a file.
#   Defaults to undef
#
# [*sa_key*]
#   The service account key. Must be passed as string not a file.
#   Defaults to undef
#
# [*sa_pub*]
#   The service account public key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*node_label*]
#  The name to assign the node in the cluster.
#  Defaults to hostname.
#   NOTE: Ignored when cloud_provider is AWS, until this lands fixed https://github.com/kubernetes/kubernetes/pull/61878
#
# [*node_extra_taints*]
# Additional taints for node.
# Example:
#   [{'key' => 'dedicated','value' => 'NewNode','effect' => 'NoSchedule', 'operator' => 'Equal'}]
#  Defaults to undef
#
# [*token*]
#   A string to use when joining nodes to the cluster. Must be in the form of '[a-z0-9]{6}.[a-z0-9]{16}'
#   Defaults to undef
#
# [*discovery_token_hash*]
#   A string to validate to the root CA public key when joining a cluster. Created by kubetool
#   Defaults to undef
#
# [*install_dashboard*]
#   This is a bool that determines if the kubernetes dashboard is installed.
#   Defaults to false
#
# [*kubernetes_dashboard_url*]
#   The URL to get the Kubernetes Dashboard yaml file.
#   Default is based on dashboard_version.
#
# [*dashboard_version*]
#   The version of Kubernetes dashboard you want to install.
#   Defaults to 1.10.1
#
# [*schedule_on_controller*]
#   A flag to remove the control plane role and allow pod scheduling on controllers
#   Defaults to true
#
# [*service_cidr*]
#   The IP assdress range for service VIPs
#   Defaults to 10.96.0.0/12
#
# [*controller_address*]
#  The IP address and Port of the controller that worker node will join. eg 172.17.10.101:6443
#  Defaults to undef
#
# [*cloud_provider*]
#  The name of the cloud provider of the cloud provider configured in /etc/kubernetes/cloud-config
#  Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#  Defaults to undef
#
# [*cloud_config*]
#  The file location of the cloud config to be used by cloud_provider [*For use with v1.12 and above*]
#  Note: this file is not managed within this module and must be present before bootstrapping the kubernetes controller
#  Defaults to undef
#
# [*image_repository*]
#  The container registry to pull control plane images from
#  Defaults to registry.k8s.io
#
# [*kubeadm_extra_config*]
#  A hash containing extra configuration data to be serialised with `to_yaml` and appended to the config.yaml file used by kubeadm.
#  Defaults to {}
#
# [*kubelet_extra_config*]
#  A hash containing extra configuration data to be serialised with `to_yaml` and appended to Kubelet configuration file for the cluster.
#  Requires DynamicKubeletConfig.
#  Defaults to {}
#
# [*kubelet_extra_arguments*]
#  A string array to be appended to kubeletExtraArgs in the Kubelet's nodeRegistration configuration applied to both control planes and nodes.
#  Use this for critical Kubelet settings such as `pod-infra-container-image` which may be problematic to configure via kubelet_extra_config
#  Defaults to []
#
# [*proxy_mode*]
# The mode for kubeproxy to run. It should be one of: "" (default), "userspace", "kernelspace", "iptables", or "ipvs".
# Defaults to ""
#
# [*pin_packages*]
#  Enable pinning of the docker and kubernetes packages to prevent accidential updates.
#  This is currently only implemented for debian based distributions.
#  Defaults to false
#
# [*kubernetes_apt_location*]
#  The APT repo URL for the Kubernetes packages.
#  Defaults to https://apt.kubernetes.io
#
# [*kubernetes_apt_release*]
#  The release name for the APT repo for the Kubernetes packages.
#  Defaults to 'kubernetes-${facts.os.distro.codename}'
#
# [*kubernetes_apt_repos*]
#  The repos to install from the Kubernetes APT url
#  Defaults to main
#
# [*kubernetes_key_id*]
#  The gpg key for the Kubernetes APT repo
#  Defaults to '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB'
#
# [*kubernetes_key_source*]
#  The URL for the APT repo gpg key
#  Defaults to https://packages.cloud.google.com/apt/doc/apt-key.gpg
#
# [*kubernetes_yum_baseurl*]
#  The YUM repo URL for the Kubernetes packages.
#  Defaults to https://download.docker.com/linux/centos/
#
# [*kubernetes_yum_gpgkey*]
#  The URL for the Kubernetes yum repo gpg key
#  Defaults to https://download.docker.com/linux/centos/gpg
#
# [*docker_apt_location*]
#  The APT repo URL for the Docker packages
#  Defaults to https://apt.dockerproject.org/repo
#
# [*docker_apt_release*]
#  The release name for the APT repo for the Docker packages.
#  Defaults to $facts.os.distro.codename
#
# [*docker_apt_repos*]
#  The repos to install from the Docker APT url
#  Defaults to main
#
# [*docker_key_id*]
#  The gpg key for the Docker APT repo
#  Defaults to '58118E89F3A912897C070ADBF76221572C52609D'
#
# [*docker_key_source*]
#  The URL for the Docker APT repo gpg key
#  Defaults to https://apt.dockerproject.org/gpg
#
# [*docker_yum_baseurl*]
#  The YUM repo URL for the Docker packages.
#  Defaults to https://download.docker.com/linux/centos/7/x86_64/stable
#
# [*docker_yum_gpgkey*]
#  The URL for the Docker yum repo gpg key
#  Defaults to https://download.docker.com/linux/centos/gpg
#
# [*docker_storage_driver*]
#  Storage Driver to be added to `/etc/docker/daemon.json`
#  Defaults to overlay2
#
# [*docker_storage_opts*]
#  Storage options to be added to `/etc/docker/daemon.json`
#  Defaults to undef
#
# [*docker_extra_daemon_config*]
#  Extra configuration to be added to `/etc/docker/daemon.json`
#  Defaults to undef
#
# [*docker_log_max_file*]
#  The maximum number of log files that can be present.
#  Defaults to 1. See https://docs.docker.com/config/containers/logging/json-file/
#
# [*docker_log_max_size*]
#  The maximum size of the log before it is rolled.
#  A positive integer plus a modifier representing the unit of measure (k, m, or g).
#  Defaults to 100m. See https://docs.docker.com/config/containers/logging/json-file/
#
# [*create_repos*]
#  A flag to install the upstream Kubernetes and Docker repos
#  Defaults to true
#
# [*disable_swap*]
#  A flag to turn off the swap setting. This is required for kubeadm.
#  Defaults to true
#
# [*manage_kernel_modules*]
#  A flag to manage required Kernel modules.
#  Defaults to true
#
# [*manage_sysctl_settings*]
#  A flag to manage required sysctl settings.
#  Defaults to true
#
# [*default_path*]
#  The path to be used when running kube* commands
#  Defaults to ['/usr/bin','/bin','/sbin','/usr/local/bin']
#
# [*cgroup_driver*]
#  The cgroup driver to be used.
#  Defaults to 'systemd'
#
# [*environment*]
#  The environment passed to kubectl commands.
#  Defaults to setting HOME and KUBECONFIG variables
#
# [*ttl_duration*]
#  Availability of the token
#  Default to 24h
#
# [*metrics_bind_address*]
#  Set the metricsBindAddress (to allow prometheus)
#  Default to 127.0.0.1
#
# [*conntrack_max_per_core*]
#  Maximum number of NAT connections to track per CPU core.
#  Set to 0 to leave the limit as-is and ignore conntrack_min.
#  Default to 32768
#
# [*conntrack_min*]
#   Minimum number of conntrack entries to allocate, regardless of conntrack-max-per-core.
#   Set conntrack_max_per_core to 0 to leave the limit as-is
#   Default to 131072
#
# [*conntrack_tcp_wait_timeout*]
#   NAT timeout for TCP connections in the CLOSE_WAIT state.
#   Default to 1h0m0s
#
# [*conntrack_tcp_stablished_timeout*]
#   Idle timeout for established TCP connections (0 to leave as-is).
#   Default to 24h0m0s
#
# [*tmp_directory*]
#   Directory to use when downloading archives for install.
#   Default to /var/tmp/puppetlabs-kubernetes
#
# [*skip_phases*]
#   Allow kubeadm init skip some phases
#   Default: none phases skipped
#
# [*skip_phases_join*]
#   Allow kubeadm join to skip some phases
#   Only works with Kubernetes 1.22+
#   Default: no phases skipped
#
# [*feature_gates*]
#  Feature gate hash to be added to kubeadm configuration
#  Example:
#   {'RootlessControlPlane' => true}
#   Default: undefined, no feature gates
#
# [*http_proxy*]
#   Configure the HTTP_PROXY environment variable
#   Defaults to undef
#
# [*https_proxy*]
#   Configure the HTTPS_PROXY environment variable
#   Defaults to undef
#
# [*no_proxy*]
#   Configure the NO_PROXY environment variable
#   Defaults to undef
#
# [*container_runtime_use_proxy*]
#   Configure whether the container runtime should be configured to use a proxy.
#   If set to true, the container runtime will use the http_proxy, https_proxy and
#   no_proxy values.
#   Defaults to false
#
# [*kubelet_use_proxy*]
#   Configure whether the kubelet should be configured to use a proxy.
#   If set to true, the kubelet will use the http_proxy, https_proxy and
#   no_proxy values.
#   Defaults to false
#
# [*api_server_count*]
#   Defaults to undef
#
# [*runc_source_checksum*]
#   Defaults to undef
#
# [*ignore_preflight_errors*]
#   Defaults to undef
#
# [*join_discovery_file*]
#   Defaults to undef
#
# [*wait_for_default_sa_tries*]
#   Defaults to 5
#
# [*wait_for_default_sa_try_sleep*]
#   Defaults to 6
#
# Authors
# -------
#
# Puppet cloud and containers team
#
#
#
class kubernetes (
  String $kubernetes_version                              = '1.10.2',
  String $kubernetes_cluster_name                         = 'kubernetes',
  String $kubernetes_package_version                      = $facts['os']['family'] ? {
    'Debian' => "${kubernetes_version}-00",
    'RedHat' => $kubernetes::kubernetes_version,
  },
  String $container_runtime                               = 'docker',
  String $containerd_version                              = '1.4.3',
  Enum['archive','package'] $containerd_install_method    = 'archive',
  String $containerd_package_name                         = 'containerd.io',
  String $docker_package_name                             = 'docker-engine',
  Optional[String] $docker_version                        = undef,
  Boolean $pin_packages                                   = false,
  String $dns_domain                                      = 'cluster.local',
  Optional[String] $cni_pod_cidr                          = undef,
  Boolean $controller                                     = false,
  Boolean $worker                                         = false,
  Boolean $manage_docker                                  = true,
  Boolean $manage_etcd                                    = true,
  Integer $kube_api_bind_port                             = 6443,
  Optional[String] $kube_api_advertise_address            = undef,
  String $etcd_version                                    = '3.2.18',
  Optional[String] $etcd_hostname                         = $facts['networking']['hostname'],
  String $etcd_data_dir                                   = '/var/lib/etcd',
  Optional[String] $etcd_ip                               = undef,
  Optional[Array] $etcd_peers                             = undef,
  Optional[String] $etcd_initial_cluster                  = undef,
  Optional[String] $etcd_discovery_srv                    = undef,
  Enum['new', 'existing'] $etcd_initial_cluster_state     = 'new',
  Enum['periodic', 'revision'] $etcd_compaction_method    = 'periodic',
  Variant[String, Integer] $etcd_compaction_retention     = 0,
  Integer $etcd_max_wals                                  = 5,
  Integer $etcd_max_request_bytes                         = 1572864,
  Optional[String] $etcd_listen_metric_urls               = undef,
  Optional[String] $etcd_ca_key                           = undef,
  Optional[String] $etcd_ca_crt                           = undef,
  Optional[String] $etcdclient_key                        = undef,
  Optional[String] $etcdclient_crt                        = undef,
  Optional[String] $etcdserver_crt                        = undef,
  Optional[String] $etcdserver_key                        = undef,
  Optional[String] $etcdpeer_crt                          = undef,
  Optional[String] $etcdpeer_key                          = undef,
  Optional[String] $cni_network_preinstall                = undef,
  Optional[String] $cni_network_provider                  = undef,
  Optional[String] $cni_provider                          = undef,
  Optional[String] $cni_rbac_binding                      = undef,
  Boolean $install_dashboard                              = false,
  String $dashboard_version                               = '1.10.1',
  Optional[String] $kubernetes_dashboard_url              = undef,
  Boolean $schedule_on_controller                         = false,
  Integer $api_server_count                               = undef,
  Boolean $delegated_pki                                  = false,
  Optional[String] $kubernetes_ca_crt                     = undef,
  Optional[String] $kubernetes_ca_key                     = undef,
  Optional[String] $kubernetes_front_proxy_ca_crt         = undef,
  Optional[String] $kubernetes_front_proxy_ca_key         = undef,
  String $token                                           = undef,
  String $ttl_duration                                    = '24h',
  String $discovery_token_hash                            = undef,
  Optional[String] $sa_pub                                = undef,
  Optional[String] $sa_key                                = undef,
  Array $apiserver_cert_extra_sans                        = [],
  Array $apiserver_extra_arguments                        = [],
  Array $controllermanager_extra_arguments                = [],
  Array $scheduler_extra_arguments                        = [],
  String $service_cidr                                    = '10.96.0.0/12',
  Optional[String] $node_label                            = undef,
  Optional[Array[Hash]] $node_extra_taints                = undef,
  Optional[String] $controller_address                    = undef,
  Optional[String] $cloud_provider                        = undef,
  Optional[String] $cloud_config                          = undef,
  Hash $apiserver_extra_volumes                           = {},
  Hash $controllermanager_extra_volumes                   = {},
  Optional[Hash] $kubeadm_extra_config                    = undef,
  Optional[Hash] $kubelet_extra_config                    = undef,
  Array $kubelet_extra_arguments                          = [],
  String $proxy_mode                                      = '',
  String $runc_version                                    = '1.0.0',
  String $runc_source                                     =
    "https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64",
  Optional[String] $runc_source_checksum                  = undef,
  String $containerd_archive                              = "containerd-${containerd_version}-linux-amd64.tar.gz",
  Optional[String] $containerd_archive_checksum           = undef,
  String $containerd_source                               =
    "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}",
  String $containerd_config_template                      = 'kubernetes/containerd/config.toml.epp',
  Variant[Stdlib::Unixpath, String] $containerd_socket    = '/run/containerd/containerd.sock',
  Optional[String] $containerd_config_source              = undef,
  Hash $containerd_plugins_registry                       = {
    'docker.io' => {
      'mirrors' => {
        'endpoint' => 'https://registry-1.docker.io',
      },
    },
  },
  Enum['runc','nvidia'] $containerd_default_runtime_name  = 'runc',
  String $containerd_sandbox_image                        = 'registry.k8s.io/pause:3.2',
  String $etcd_archive                                    = "etcd-v${etcd_version}-linux-amd64.tar.gz",
  Optional[String] $etcd_archive_checksum                 = undef,
  String $etcd_package_name                               = 'etcd-server',
  String $etcd_source                                     = "https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/${etcd_archive}",
  String $etcd_install_method                             = 'wget',
  Optional[String] $kubernetes_apt_location               = undef,
  Optional[String] $kubernetes_apt_release                = undef,
  Optional[String] $kubernetes_apt_repos                  = undef,
  Optional[String] $kubernetes_key_id                     = undef,
  Optional[String] $kubernetes_key_source                 = undef,
  Optional[String] $kubernetes_yum_baseurl                = undef,
  Optional[String] $kubernetes_yum_gpgkey                 = undef,
  Optional[String] $docker_apt_location                   = undef,
  Optional[String] $docker_apt_release                    = undef,
  Optional[String] $docker_apt_repos                      = undef,
  Optional[String] $docker_yum_baseurl                    = undef,
  Optional[String] $docker_yum_gpgkey                     = undef,
  Optional[String] $docker_key_id                         = undef,
  Optional[String] $docker_key_source                     = undef,
  String $docker_storage_driver                           = 'overlay2',
  Optional[Array] $docker_storage_opts                    = $facts['os']['family'] ? {
    'RedHat' => ['overlay2.override_kernel_check=true'],
    default  => undef,
  },
  Optional[String] $docker_extra_daemon_config            = undef,
  Optional[String] $http_proxy                            = undef,
  Optional[String] $https_proxy                           = undef,
  Optional[String] $no_proxy                              = undef,
  Boolean $container_runtime_use_proxy                    = false,
  Boolean $kubelet_use_proxy                              = false,
  String $docker_log_max_file                             = '1',
  String $docker_log_max_size                             = '100m',
  Boolean $disable_swap                                   = true,
  Boolean $manage_kernel_modules                          = true,
  Boolean $manage_sysctl_settings                         = true,
  Boolean $create_repos                                   = true,
  String $image_repository                                = 'registry.k8s.io',
  Array[String] $default_path                             = ['/usr/bin', '/usr/sbin', '/bin', '/sbin', '/usr/local/bin'],
  String $cgroup_driver                                   = 'systemd',
  Array[String] $environment                              = $controller ? {
    true    => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
    default => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/kubelet.conf'],
  },
  Optional[Array] $ignore_preflight_errors                = undef,
  Stdlib::IP::Address $metrics_bind_address               = '127.0.0.1',
  Optional[String] $join_discovery_file                   = undef,
  Optional[String] $skip_phases                           = undef,
  Optional[Array] $skip_phases_join                       = undef,
  Integer $conntrack_max_per_core                         = 32768,
  Integer $conntrack_min                                  = 131072,
  String $conntrack_tcp_wait_timeout                      = '1h0m0s',
  String $conntrack_tcp_stablished_timeout                = '24h0m0s',
  String $tmp_directory                                   = '/var/tmp/puppetlabs-kubernetes',
  Integer $wait_for_default_sa_tries                      = 5,
  Integer $wait_for_default_sa_try_sleep                  = 6,
  Hash[String[1], Boolean] $feature_gates                 = {},
) {
  if !$facts['os']['family'] in ['Debian', 'RedHat'] {
    notify { "The OS family ${facts['os']['family']} is not supported by this module": }
  }

  if versioncmp($dashboard_version, '2.0.0') >= 0 {
    $dashboard_url = pick($kubernetes_dashboard_url, "https://raw.githubusercontent.com/kubernetes/dashboard/v${dashboard_version}/aio/deploy/recommended.yaml")
  } else {
    $dashboard_url = pick($kubernetes_dashboard_url, "https://raw.githubusercontent.com/kubernetes/dashboard/v${dashboard_version}/src/deploy/recommended/kubernetes-dashboard.yaml")
  }

  # Some cloud providers override or fix the node name, so we can't override
  case $cloud_provider {
    # k8s controller in AWS with delete any nodes it can't query in the metadata
    'aws': {
      $node_name = $facts['ec2_metadata']['hostname']
      if (!empty($node_label) and $node_label != $node_name) {
        notify { 'aws_name_override':
          message => "AWS provider requires node name to match AWS metadata: ${node_name}, ignoring node label ${node_label}",
        }
      }
    }
    default: { $node_name = pick($node_label, fact('networking.hostname')) }
  }

  if $controller {
    if $worker {
      fail('A node can not be both a controller and a node')
    }
  }

  # Not sure if should allow this to be changed
  $config_file = '/etc/kubernetes/config.yaml'

  if $controller {
    include kubernetes::repos
    include kubernetes::packages
    include kubernetes::config::kubeadm
    include kubernetes::service
    include kubernetes::cluster_roles
    include kubernetes::kube_addons
    contain kubernetes::repos
    contain kubernetes::packages
    contain kubernetes::config::kubeadm
    contain kubernetes::service
    contain kubernetes::cluster_roles
    contain kubernetes::kube_addons

    Class['kubernetes::repos']
    -> Class['kubernetes::packages']
    -> Class['kubernetes::config::kubeadm']
    -> Class['kubernetes::service']
    -> Class['kubernetes::cluster_roles']
    -> Class['kubernetes::kube_addons']
  }

  if $worker {
    contain kubernetes::repos
    contain kubernetes::packages
    # K8s 1.10/1.11 can't use config files
    unless $kubernetes_version =~ /^1.1(0|1)/ {
      contain kubernetes::config::worker
      Class['kubernetes::config::worker'] -> Class['kubernetes::service']
    }
    contain kubernetes::service
    contain kubernetes::cluster_roles

    Class['kubernetes::repos']
    -> Class['kubernetes::packages']
    -> Class['kubernetes::service']
    -> Class['kubernetes::cluster_roles']
  }
}
