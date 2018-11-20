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
#   An example with hiera would be kubernetes::kube_api_advertise_address: "%{::ipaddress_enp0s8}"
#   defaults to undef
#
# [*etcd_version*]
#   The version of etcd that you would like to use.
#   Defaults to 3.1.12
#
# [*etcd_archive*]
#  The name of the etcd archive
#  Defaults to etcd-v${etcd_version}-linux-amd64.tar.gz
#
# [*etcd_source*]
#  The URL to download the etcd archive
#  Defaults to https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}
#
# [*runc_version*]
#  The version of runc to install
#  Defaults to 1.0.0-rc5
#
# [*runc_source*]
#  The URL to download runc
#  Defaults to https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64
#  
# [*etcd_ip*]
#   The ip address that you want etcd to use for communications.
#   An example with hiera would be kubernetes::etcd_ip: "%{::ipaddress_enp0s8}"
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
# [*kubernetes_ca_crt*]
#   The clusters ca certificate. Must be passed as a string not a file.
#   Defaults to undef
#
# [*kubernetes_ca_key*]
#   The clusters ca key. Must be passed as a string not a file.
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
#  Defaults to hostname
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
#  A hash containing extra configuration data to be serialised with `to_yaml` and appended to Kubelet configuration file for the cluster. Requires DynamicKubeletConfig.
#  Defaults to {}
#
# [*kubelet_extra_arguments*]
#  A string array to be appended to kubeletExtraArgs in the Kubelet's nodeRegistration configuration. It is applied to both masters and nodes. Use this for critical Kubelet settings such as `pod-infra-container-image` which may be problematic to configure via kubelet_extra_config and DynamicKubeletConfig.
#  Defaults to []
#
# [*kubernetes_apt_location*]
#  The APT repo URL for the Kubernetes packages.
#  Defaults to https://apt.kubernetes.io
#
# [*kubernetes_apt_release*]
#  The release name for the APT repo for the Kubernetes packages.
#  Defaults to 'kubernetes-${::lsbdistcodename}'
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
#  Defaults to 'ubuntu-${::lsbdistcodename}'
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
# Authors
# -------
#
# Puppet cloud and containers team
#
#
#
class kubernetes (
  String $kubernetes_version                   = '1.10.2',
  String $kubernetes_package_version           = $::osfamily ? {
                                                    'Debian' => "${kubernetes_version}-00",
                                                    'RedHat' => $kubernetes::kubernetes_version,
                                                  },
  String $container_runtime                    = 'docker',
  Optional[String] $containerd_version         = '1.1.0',
  Optional[String] $docker_package_name        = 'docker-engine',
  Optional[String] $docker_version             = $::osfamily ? {
                                                    'Debian' => '17.03.0~ce-0~ubuntu-xenial',
                                                    'RedHat' => '17.03.1.ce-1.el7.centos',
                                                  },
  Optional[String] $cni_pod_cidr               = undef,
  Boolean $controller                          = false,
  Boolean $worker                              = false,
  Boolean $manage_docker                       = true,
  Boolean $manage_etcd                         = true,
  Optional[String] $kube_api_advertise_address = undef,
  Optional[String] $etcd_version               = '3.1.12',
  Optional[String] $etcd_ip                    = undef,
  Optional[Array] $etcd_peers                  = undef,
  Optional[String] $etcd_initial_cluster       = undef,
  String $etcd_ca_key                          = undef,
  String $etcd_ca_crt                          = undef,
  String $etcdclient_key                       = undef,
  String $etcdclient_crt                       = undef,
  Optional[String] $etcdserver_crt             = undef,
  Optional[String] $etcdserver_key             = undef,
  Optional[String] $etcdpeer_crt               = undef,
  Optional[String] $etcdpeer_key               = undef,
  Optional[String] $cni_network_provider       = undef,
  Optional[String] $cni_rbac_binding           = undef,
  Boolean $install_dashboard                   = false,
  Boolean $schedule_on_controller              = false,
  Integer $api_server_count                    = undef,
  String $kubernetes_ca_crt                    = undef,
  String $kubernetes_ca_key                    = undef,
  String $token                                = undef,
  String $discovery_token_hash                 = undef,
  String $sa_pub                               = undef,
  String $sa_key                               = undef,
  Optional[Array] $apiserver_cert_extra_sans   = [],
  Optional[Array] $apiserver_extra_arguments   = [],
  String $service_cidr                         = '10.96.0.0/12',
  String $node_label                           = $::hostname,
  Optional[String] $controller_address         = undef,
  Optional[String] $cloud_provider             = undef,
  Optional[String] $cloud_config               = undef,
  Optional[Hash] $kubeadm_extra_config         = undef,
  Optional[Hash] $kubelet_extra_config         = undef,
  Optional[Array] $kubelet_extra_arguments     = [],
  Optional[String] $runc_version               = '1.0.0-rc5',
  Optional[String] $runc_source                =
    "https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64",
  Optional[String] $containerd_archive         = "containerd-${containerd_version}.linux-amd64.tar.gz",
  Optional[String] $containerd_source          =
    "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}",
  String $etcd_archive                         = "etcd-v${etcd_version}-linux-amd64.tar.gz",
  String $etcd_source                          = "https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}",
  Optional[String] $kubernetes_apt_location    = 'http://apt.kubernetes.io',
  Optional[String] $kubernetes_apt_release     = "kubernetes-${::lsbdistcodename}",
  Optional[String] $kubernetes_apt_repos       = 'main',
  Optional[String] $kubernetes_key_id          = '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
  Optional[String] $kubernetes_key_source      = 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
  Optional[String] $kubernetes_yum_baseurl     = 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
  Optional[String] $kubernetes_yum_gpgkey      = 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
  Optional[String] $docker_apt_location        = 'https://apt.dockerproject.org/repo',
  Optional[String] $docker_apt_release         = "ubuntu-${::lsbdistcodename}",
  Optional[String] $docker_apt_repos           = 'main',
  Optional[String] $docker_yum_baseurl         = 'https://yum.dockerproject.org/repo/main/centos/7',
  Optional[String] $docker_yum_gpgkey          = 'https://yum.dockerproject.org/gpg',
  Optional[String] $docker_key_id              = '58118E89F3A912897C070ADBF76221572C52609D',
  Optional[String] $docker_key_source          = 'https://apt.dockerproject.org/gpg',
  Boolean $disable_swap                        = true,
  Boolean $manage_kernel_modules               = true,
  Boolean $manage_sysctl_settings              = true,
  Boolean $create_repos                        = true,
  String $image_repository                     = 'k8s.gcr.io',
){
  if ! $::osfamily in ['Debian','RedHat'] {
    notify {"The OS family ${::osfamily} is not supported by this module":}
  }

  if $controller {
    if $worker {
      fail(translate('A node can not be both a controller and a node'))
    }
  }

  if $controller {
    include kubernetes::repos
    include kubernetes::packages
    include kubernetes::config
    include kubernetes::service
    include kubernetes::cluster_roles
    include kubernetes::kube_addons
    contain kubernetes::repos
    contain kubernetes::packages
    contain kubernetes::config
    contain kubernetes::service
    contain kubernetes::cluster_roles
    contain kubernetes::kube_addons

    Class['kubernetes::repos']
      -> Class['kubernetes::packages']
      -> Class['kubernetes::config']
      -> Class['kubernetes::service']
      -> Class['kubernetes::cluster_roles']
      -> Class['kubernetes::kube_addons']
  }

  if $worker {
    include kubernetes::repos
    include kubernetes::packages
    include kubernetes::service
    include kubernetes::cluster_roles
    contain kubernetes::repos
    contain kubernetes::packages
    contain kubernetes::service
    contain kubernetes::cluster_roles

    Class['kubernetes::repos']
      -> Class['kubernetes::packages']
      -> Class['kubernetes::service']
      -> Class['kubernetes::cluster_roles']
  }
}
