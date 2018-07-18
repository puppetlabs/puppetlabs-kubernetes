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
#   Defaults to `docker`.
#
# [*containerd_version*]
#   This is the version of the containerd runtime the module will install.
#   Defaults to 1.1.0
#
# [*docker_repo_name*]
#   The name of the docker repo.
#   Defaults to `docker`.
#
# [*docker_package_name*]
#   The name of the docker package you would like to install.
#   Defaults to `docker-engine`.
#
# [*docker_version*]
#   This is the version of the docker runtime that you want to install.
#   Defaults to 17.03.0.ce-1.el7.centos on RedHat
#   Defaults to 17.03.0~ce-0~ubuntu-xenial on Debian
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
# [*controller*]
#   This is a bool that sets the node as a Kubernetes controller
#   Defaults to false
#
# [*worker*]
#   This is a bool that sets a node to a worker.
#   defaults to false 
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
# Authors
# -------
#
# Puppet cloud and containers team
#
#
#
class kubernetes (
  String $kubernetes_version                                       = $kubernetes::params::kubernetes_version,
  String $kubernetes_package_version                               = $kubernetes::params::kubernetes_package_version,
  String $container_runtime                                        = $kubernetes::params::container_runtime,
  Optional[String] $containerd_version                             = $kubernetes::params::containerd_version,
  Optional[String] $docker_version                                 = $kubernetes::params::docker_version,
  Optional[String] $cni_pod_cidr                                   = $kubernetes::params::cni_pod_cidr,
  Optional[String] $docker_repo_name                               = $kubernetes::params::docker_repo_name,
  Optional[String] $docker_package_name                            = $kubernetes::params::docker_package_name,
  Boolean $controller                                              = $kubernetes::params::controller,
  Boolean $worker                                                  = $kubernetes::params::worker,
  Optional[String] $kube_api_advertise_address                     = $kubernetes::params::kube_api_advertise_address,
  Optional[String] $etcd_version                                   = $kubernetes::params::etcd_version,
  Optional[String] $etcd_ip                                        = $kubernetes::params::etcd_ip,
  Optional[Array] $etcd_peers                                      = $kubernetes::params::etcd_peers,
  Optional[String] $etcd_initial_cluster                           = $kubernetes::params::etcd_initial_cluster,
  String $etcd_ca_key                                              = $kubernetes::params::etcd_ca_key,
  String $etcd_ca_crt                                              = $kubernetes::params::etcd_ca_crt,
  String $etcdclient_key                                           = $kubernetes::params::etcdclient_key,
  String $etcdclient_crt                                           = $kubernetes::params::etcdclient_crt,
  Optional[String] $etcdserver_crt                                 = $kubernetes::params::etcdserver_crt,
  Optional[String] $etcdserver_key                                 = $kubernetes::params::etcdserver_key,
  Optional[String] $etcdpeer_crt                                   = $kubernetes::params::etcdpeer_crt,
  Optional[String] $etcdpeer_key                                   = $kubernetes::params::etcdpeer_key,
  Optional[String] $cni_network_provider                           = $kubernetes::params::cni_network_provider,
  Boolean $install_dashboard                                       = $kubernetes::params::install_dashboard,
  Boolean $schedule_on_controller                                  = $kubernetes::params::schedule_on_controller,
  Integer $api_server_count                                        = $kubernetes::params::api_server_count,
  String $kubernetes_ca_crt                                        = $kubernetes::params::kubernetes_ca_crt,
  String $kubernetes_ca_key                                        = $kubernetes::params::kubernetes_ca_key,
  String $token                                                    = $kubernetes::params::token,
  String $discovery_token_hash                                     = $kubernetes::params::discovery_token_hash,
  String $sa_pub                                                   = $kubernetes::params::sa_pub,
  String $sa_key                                                   = $kubernetes::params::sa_key,
  Optional[Array] $apiserver_cert_extra_sans                       = $kubernetes::params::apiserver_cert_extra_sans,
  Optional[Array] $apiserver_extra_arguments                       = $kubernetes::params::apiserver_extra_arguments,
  String $service_cidr                                             = $kubernetes::params::service_cidr,
  String $node_label                                               = $kubernetes::params::node_label,
  Optional[String] $controller_address                             = $kubernetes::params::controller_address,
  Optional[String] $cloud_provider                                 = $kubernetes::params::cloud_provider,

  )  inherits kubernetes::params {

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
