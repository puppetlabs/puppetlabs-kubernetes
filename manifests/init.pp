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
#   Defaults to cri_containerd
#
# [*containerd_version*]
#   This is the version of the containerd runtime the module will install.
#   Defaults to 1.1.0
#
# [*containerd_archive*]
#  The name of the containerd archive
#  Defaults to containerd-${containerd_version}.linux-amd64.tar.gz
#
# [*containerd_source*]
#  The URL to download the containerd archive
#  Defaults to https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}
#
# [*docker_version*]
#   This is the version of the docker runtime that you want to install.
#   Defaults to 17.03.0.ce-1.el7.centos on RedHat
#   Defaults to 17.03.0~ce-0~ubuntu-xenial on Ubuntu
#
# [*docker_package_name*]
#  The docker package name to download from an upstream repo
#  Defaults to docker-engine
#
# [*cni_pod_cidr*]
#   The overlay (internal) network range to use.
#   Defaults to undef. kube_tool sets this per cni provider.
#
# [*cni_network_provider*]
#
#  The URL to get the cni providers yaml file.
#  Defaults to `undef`. `kube_tool` sets this value.
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
# [*etcd_version*]
#   The version of etcd that you would like to use.
#   Defaults to 3.2.18
#
# [*etcd_archive*]
#  The name of the etcd archive
#  Defaults to etcd-v${etcd_version}-linux-amd64.tar.gz
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
#  Defaults to 1.0.0-rc5
#
# [*runc_source*]
#  The URL to download runc
#  Defaults to https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64
#
# [*etcd_hostname*]
#   The name of the etcd instance.
#   An example with hiera would be kubernetes::etcd_hostname: "%{::fqdn}"
#   Defaults to hostname
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
# [*etcd_initial_cluster*]
#    This will tell etcd how many nodes will be in the cluster and is passed as a string.
#   An example with hiera would be kubernetes::etcd_initial_cluster: etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380
#   Defaults to undef
#
# [*etcd_initial_cluster_state*]
#     This will tell etcd the initial state of the cluster. Useful for adding a node to the cluster. Allowed values are
#   "new" or "existing"
#   Defaults to "new"
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
#   Defaults to the upstream source. `kube_tool` sets this value.
#
# [*dashboard_version*]
#   The version of Kubernetes dashboard you want to install.
#   Defaults to v1.10.1
#
# [*schedule_on_controller*]
#   A flag to remove the master role and allow pod scheduling on controllers
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
#  Defaults to k8s.gcr.io
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
#  A string array to be appended to kubeletExtraArgs in the Kubelet's nodeRegistration configuration applied to both masters and nodes.
#  Use this for critical Kubelet settings such as `pod-infra-container-image` which may be problematic to configure via kubelet_extra_config
#  Defaults to []
#
# [*proxy_mode*]
# The mode for kubeproxy to run. It should be one of: "" (default), "userspace", "kernelspace", "iptables", or "ipvs".
# Defaults to ""
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
#  Defaults to https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
#
# [*kubernetes_yum_gpgkey*]
#  The URL for the Kubernetes yum repo gpg key
#  Defaults to https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
#
# [*docker_apt_location*]
#  The APT repo URL for the Docker packages
#  Defaults to https://apt.dockerproject.org/repo
#
# [*docker_apt_release*]
#  The release name for the APT repo for the Docker packages.
#  Defaults to 'ubuntu-${facts.os.distro.codename}'
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
#  Defaults to https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
#
# [*docker_yum_gpgkey*]
#  The URL for the Docker yum repo gpg key
#  Defaults to https://yum.dockerproject.org/gpg
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
#  Defaults to 'systemd' on EL and 'cgroupfs' otherwise
#
# [*environment*]
# The environment passed to kubectl commands.
# Defaults to setting HOME and KUBECONFIG variables
#
# [*ttl_duration*]
# Availability of the token
# Default to 24h
#
# [*metrics_bind_address*]
# Set the metricsBindAddress (to allow prometheus)
# Default to 127.0.0.1
#
# Authors
# -------
#
# Puppet cloud and containers team
#
#
#
class kubernetes (
  String $kubernetes_version                         = '1.10.2',
  String $kubernetes_cluster_name                    = 'kubernetes',
  String $kubernetes_package_version                 = $facts['os']['family'] ? {
                                                          'Debian' => "${kubernetes_version}-00",
                                                          'RedHat' => $kubernetes::kubernetes_version,
                                                        },
  String $container_runtime                          = 'docker',
  Optional[String] $containerd_version               = '1.1.0',
  Optional[String] $docker_package_name              = 'docker-engine',
  Optional[String] $docker_version                   = $facts['os']['family'] ? {
                                                          'Debian' => '17.03.0~ce-0~ubuntu-xenial',
                                                          'RedHat' => '17.03.1.ce-1.el7.centos',
                                                        },
  Optional[String] $cni_pod_cidr                     = undef,
  Boolean $controller                                = false,
  Boolean $worker                                    = false,
  Boolean $manage_docker                             = true,
  Boolean $manage_etcd                               = true,
  Optional[String] $kube_api_advertise_address       = undef,
  Optional[String] $etcd_version                     = '3.2.18',
  Optional[String] $etcd_hostname                    = $facts['hostname'],
  Optional[String] $etcd_ip                          = undef,
  Optional[Array] $etcd_peers                        = undef,
  Optional[String] $etcd_initial_cluster             = undef,
  Optional[Enum['new','existing']] $etcd_initial_cluster_state = 'new',
  String $etcd_ca_key                                = undef,
  String $etcd_ca_crt                                = undef,
  String $etcdclient_key                             = undef,
  String $etcdclient_crt                             = undef,
  Optional[String] $etcdserver_crt                   = undef,
  Optional[String] $etcdserver_key                   = undef,
  Optional[String] $etcdpeer_crt                     = undef,
  Optional[String] $etcdpeer_key                     = undef,
  Optional[String] $cni_network_provider             = undef,
  Optional[String] $cni_rbac_binding                 = undef,
  Boolean $install_dashboard                         = false,
  String $dashboard_version                          = 'v1.10.1',
  String $kubernetes_dashboard_url                   =
  "https://raw.githubusercontent.com/kubernetes/dashboard/${dashboard_version}/src/deploy/recommended/kubernetes-dashboard.yaml",
  Boolean $schedule_on_controller                    = false,
  Integer $api_server_count                          = undef,
  String $kubernetes_ca_crt                          = undef,
  String $kubernetes_ca_key                          = undef,
  String $kubernetes_front_proxy_ca_crt              = undef,
  String $kubernetes_front_proxy_ca_key              = undef,
  String $token                                      = undef,
  String $ttl_duration                               = '24h',
  String $discovery_token_hash                       = undef,
  String $sa_pub                                     = undef,
  String $sa_key                                     = undef,
  Optional[Array] $apiserver_cert_extra_sans         = [],
  Optional[Array] $apiserver_extra_arguments         = [],
  Optional[Array] $controllermanager_extra_arguments = [],
  String $service_cidr                               = '10.96.0.0/12',
  Optional[String] $node_label                       = undef,
  Optional[String] $controller_address               = undef,
  Optional[String] $cloud_provider                   = undef,
  Optional[String] $cloud_config                     = undef,
  Optional[Hash] $apiserver_extra_volumes            = {},
  Optional[Hash] $controllermanager_extra_volumes    = {},
  Optional[Hash] $kubeadm_extra_config               = undef,
  Optional[Hash] $kubelet_extra_config               = undef,
  Optional[Array] $kubelet_extra_arguments           = [],
  Optional[String] $proxy_mode                       = '',
  Optional[String] $runc_version                     = '1.0.0-rc5',
  Optional[String] $runc_source                      =
    "https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64",
  Optional[String] $containerd_archive               = "containerd-${containerd_version}.linux-amd64.tar.gz",
  Optional[String] $containerd_source                =
    "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}",
  String $etcd_archive                               = "etcd-v${etcd_version}-linux-amd64.tar.gz",
  String $etcd_package_name                          = 'etcd-server',
  String $etcd_source                                = "https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}",
  String $etcd_install_method                        = 'wget',
  Optional[String] $kubernetes_apt_location          = undef,
  Optional[String] $kubernetes_apt_release           = undef,
  Optional[String] $kubernetes_apt_repos             = undef,
  Optional[String] $kubernetes_key_id                = undef,
  Optional[String] $kubernetes_key_source            = undef,
  Optional[String] $kubernetes_yum_baseurl           = undef,
  Optional[String] $kubernetes_yum_gpgkey            = undef,
  Optional[String] $docker_apt_location              = undef,
  Optional[String] $docker_apt_release               = undef,
  Optional[String] $docker_apt_repos                 = undef,
  Optional[String] $docker_yum_baseurl               = undef,
  Optional[String] $docker_yum_gpgkey                = undef,
  Optional[String] $docker_key_id                    = undef,
  Optional[String] $docker_key_source                = undef,
  Optional[String] $docker_storage_driver            = 'overlay2',
  Optional[Array] $docker_storage_opts               = $facts['os']['family'] ? {
                                                          'RedHat' => ['overlay2.override_kernel_check=true'],
                                                          default  => undef,
                                                      },
  Optional[String] $docker_extra_daemon_config       = undef,
  String $docker_log_max_file                        = '1',
  String $docker_log_max_size                        = '100m',
  Boolean $disable_swap                              = true,
  Boolean $manage_kernel_modules                     = true,
  Boolean $manage_sysctl_settings                    = true,
  Boolean $create_repos                              = true,
  String $image_repository                           = 'k8s.gcr.io',
  Array[String] $default_path                        = ['/usr/bin','/bin','/sbin','/usr/local/bin'],
  String $cgroup_driver                              = $facts['os']['family'] ? {
                                                          'RedHat' => 'systemd',
                                                          default  => 'cgroupfs',
                                                        },
  Array[String] $environment                         = $controller ? {
                                                          true    => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                                                          default => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/kubelet.conf'],
                                                        },
  Optional[Array] $ignore_preflight_errors           = undef,
  Stdlib::IP::Address $metrics_bind_address          = '127.0.0.1',
){
  if ! $facts['os']['family'] in ['Debian','RedHat'] {
    notify {"The OS family ${facts['os']['family']} is not supported by this module":}
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
      fail(translate('A node can not be both a controller and a node'))
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
