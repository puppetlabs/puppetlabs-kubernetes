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
#   Defaults to  1.9.2
#
# [*kubernetes_package_version*]
#   The version of the packages the Kubernetes os packages to install
#   ie kubectl and kubelet
#   Defaults to 1.9.2
#
# [*container_runtime]
#   This is the runtime that the Kubernetes cluster will use.
#   It can only be set to "cri_containerd" or "docker"
#   Defaults to docker
#
# [*cni_version*]
#   The version of the cni package you would like to install
#   Defaults to 0.6.0
#
# [*cni_provider]
#   The url location for the cni providers yaml. This can only be set to weave or flannel.
#   Defaults to undef
#
# [*kube_dns_version*]
#   The version of kube DNS you would like to install
#   Defaults to 1.14.2
#
# [*controller*]
#   This is a bool that sets the node as a Kubernetes controller
#   Defaults to false
#
# [*bootstrap_controller*]
#   This sets the node to use as the bootstrap controller
#   The bootstrap controller is only used for initial cluster creation
#   Defaults to false
#
# [*bootstrap_controller_ip*]
#   The ip address of the bootstrap controller.
#   defaults to undef
#
# [*worker*]
#   This is a bool that sets a node to a worker.
#   defaults to undef
#
# [*kube_api_advertise_address*]
#   This is the ip address that the want to api server to expose.
#   An example with hiera would be kubernetes::kube_api_advertise_address: "%{::ipaddress_enp0s8}"
#   defaults to undef
#
# [*$apiserver_extra_arguments*]
#   This is an array to pass extra configuration to the Kubernetes api.
#   Defaults to []
#
# [*etcd_version*]
#   The version of etcd that you would like to use.
#   Defaults to 3.0.17
#
# [*etcd_ip*]
#   The ip address that you want etcd to use for communications.
#   An example with hiera would be kubernetes::etcd_ip: "%{::ipaddress_enp0s8}"
#   Defaults to undef
#
# [*etcd_initial_cluster*]
#   This will tell etcd how many nodes will be in the cluster and is passed as a string.
#   An example with hiera would be kubernetes::etcd_initial_cluster: etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380
#   Defaults to undef
#
# [*bootstrap_token*]
#   This is the token Kubernetes will use to start components.
#   For more information around bootstrap tokens please see https://kubernetes.io/docs/admin/bootstrap-tokens/
#   Defaults to undef
#
# [*bootstrap_token_name*]
#   This is the name of the bootstrap token.
#   An example with hiera would be kubernetes::bootstrap_token_name: bootstrap-token-95e1e0
#   Defaults to undef
#
# [*bootstrap_token_description*]
#   The boot strap token description, this must be base64 encoded.
# lint:ignore:140chars
#   An example with hierawould be  kubernetes::bootstrap_token_description: VGhlIGRlZmF1bHQgYm9vdHN0cmFwIHRva2VuIHBhc3NlZCB0byB0aGUgY2x1c3RlciB2aWEgUHVwcGV0Lg==
# lint:endignore
#
# [*bootstrap_token_id*]
#   This is the id the cluster will use to point to the token, this must be base64 encoded.
#   An example with hiera would be kubernetes::bootstrap_token_id: OTVlMWUwDQo=
#   Defaults to undef
#
# [*bootstrap_token_secret*]
#   This is the secret to validate the boot strap token, this must be base64 encoded.
#   An example with hiera would be kubernetes::bootstrap_token_secret: OTVlMWUwLmFlMmUzYjkwYTdmYjlkMzYNCg==
#   Defaults to undef
#
# [*bootstrap_token_usage_bootstrap_authentication*]
#   This is the bool to use the boot strap token, this must be base64 encoded. (true = dHJ1ZQ==)
#   An example with hiera would be kubernetes::bootstrap_token_usage_bootstrap_authentication: dHJ1ZQ==
#   Defaults to undef
#
# [*bootstrap_token_usage_bootstrap_signing*]
#   This is a bool to use boot trap signing, , this must be base64 encoded. (true = dHJ1ZQ==)
#   An example with hiera would be kubernetes::bootstrap_token_usage_bootstrap_signing: dHJ1ZQ==
#   Defaults to undef
#
# [*certificate_authority_data*]
#   This is the ca certificate data for the cluster. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_certificate_data_controller*]
#   This is the client certificate data for the controllers. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_certificate_data_controller_manager*]
#   This is the client certificate data for the controller manager. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_certificate_data_scheduler*]
#   This is the client certificate data for the scheduler. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_certificate_data_worker*]
#   This is the client certificate data for the kubernetes workers. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_key_data_controller*]
#   This is the client certificate key for the controllers. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_key_data_controller_manager*]
#   This is the client certificate key for the controller manager. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_key_data_scheduler*]
#   This is the client certificate key for the scheduler. This must be passed as string not as a file.
#   Defaults to undef
#
# [*client_key_data_worker*]
#   This is the client certificate key for the kubernetes workers. This must be passed as string not as a file.
#   Defaults to undef
#
# [*apiserver_kubelet_client_crt*]
#   The kubelet api server certificate. Must be passed as cert not a file.
#   Defaults to undef
#
# [*apiserver_kubelet_client_key*]
#   The kubelet api server key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*apiserver_crt*]
#   The api server certificate. Must be passed as cert not a file.
#   Defaults to undef
#
# [*apiserver_key*]
#   The api server key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*apiserver_extra_arguments*]
#   A string array of extra arguments to be passed to the api server.
#   Defaults to []
#
# [*ca_crt*]
#   The clusters ca certificate. Must be passed as cert not a file.
#   Defaults to undef
#
# [*ca_key*]
#   The clusters ca key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*front_proxy_ca_crt*]
#   The front proxy ca certificate. Must be passed as cert not a file.
#   Defaults to undef
#
# [*front_proxy_ca_key*]
#   The front proxy ca key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*front_proxy_client_crt*]
#   The front proxy client certificate. Must be passed as cert not a file.
#   Defaults to undef
#
# [*front_proxy_client_key*]
#   The front proxy client key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*sa_key*]
#   The service account key. Must be passed as cert not a file.
#   Defaults to undef
#
# [*sa_pub*]
#  The service account public key. Must be passed as cert not a file.
#  Defaults to undef
#
# [*cni_network_provider*]
#   This is the url that kubectl can find the networking deployment.
#   We will support any networking provider that supports cni
#   This defaults to https://git.io/weave-kube-1.6
#
# [*install_dashboard*]
#   This is a bool that determines if the kubernetes dashboard is installed.
#   Defaults to false
#
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
  Optional[String] $kubernetes_package_version                     = $kubernetes::params::kubernetes_package_version,
  String $kubernetes_fqdn                                          = $kubernetes::params::kubernetes_fqdn,
  String $container_runtime                                        = $kubernetes::params::container_runtime,
  Optional[String] $cni_version                                    = $kubernetes::params::cni_version,
  Optional[String] $cni_cluster_cidr                               = $kubernetes::params::cni_cluster_cidr,
  Optional[String] $cni_node_cidr                                  = $kubernetes::params::cni_node_cidr,
  String $kube_dns_version                                         = $kubernetes::params::kube_dns_version,
  Boolean $controller                                              = $kubernetes::params::controller,
  Boolean $bootstrap_controller                                    = $kubernetes::params::bootstrap_controller,
  Optional[String] $bootstrap_controller_ip                        = $kubernetes::params::bootstrap_controller_ip,
  Boolean $worker                                                  = $kubernetes::params::worker,
  Optional[String] $kube_api_advertise_address                     = $kubernetes::params::kube_api_advertise_address,
  String $etcd_version                                             = $kubernetes::params::etcd_version,
  Optional[String] $etcd_ip                                        = $kubernetes::params::etcd_ip,
  Optional[String] $etcd_initial_cluster                           = $kubernetes::params::etcd_initial_cluster,
  Optional[String] $bootstrap_token                                = $kubernetes::params::bootstrap_token,
  Optional[String] $bootstrap_token_name                           = $kubernetes::params::bootstrap_token_name,
  Optional[String] $bootstrap_token_description                    = $kubernetes::params::bootstrap_token_description,
  Optional[String] $bootstrap_token_id                             = $kubernetes::params::bootstrap_token_id,
  Optional[String] $bootstrap_token_secret                         = $kubernetes::params::bootstrap_token_secret,
  Optional[String] $bootstrap_token_usage_bootstrap_authentication = $kubernetes::params::bootstrap_token_usage_bootstrap_authentication,
  Optional[String] $bootstrap_token_expiration                     = $kubernetes::params::bootstrap_token_expiration,
  Optional[String] $bootstrap_token_usage_bootstrap_signing        = $kubernetes::params::bootstrap_token_usage_bootstrap_signing,
  Optional[String] $certificate_authority_data                     = $kubernetes::params::certificate_authority_data,
  Optional[String] $client_certificate_data_controller             = $kubernetes::params::client_certificate_data_controller,
  Optional[String] $client_certificate_data_controller_manager     = $kubernetes::params::client_certificate_data_controller_manager,
  Optional[String] $client_certificate_data_scheduler              = $kubernetes::params::client_certificate_data_scheduler,
  Optional[String] $client_certificate_data_worker                 = $kubernetes::params::client_certificate_data_worker,
  Optional[String] $client_certificate_data_admin                  = $kubernetes::params::client_certificate_data_admin,
  Optional[String] $client_key_data_controller                     = $kubernetes::params::client_key_data_controller,
  Optional[String] $client_key_data_controller_manager             = $kubernetes::params::client_key_data_controller_manager,
  Optional[String] $client_key_data_scheduler                      = $kubernetes::params::client_key_data_scheduler,
  Optional[String] $client_key_data_worker                         = $kubernetes::params::client_key_data_worker,
  Optional[String] $client_key_data_admin                          = $kubernetes::params::client_key_data_admin,
  Optional[String] $apiserver_kubelet_client_crt                   = $kubernetes::params::apiserver_kubelet_client_crt,
  Optional[String] $apiserver_kubelet_client_key                   = $kubernetes::params::apiserver_kubelet_client_key,
  Optional[String] $apiserver_crt                                  = $kubernetes::params::apiserver_crt,
  Optional[String] $apiserver_key                                  = $kubernetes::params::apiserver_key,
  Array $apiserver_extra_arguments                                 = $kubernetes::params::apiserver_extra_arguments,
  Optional[String] $ca_crt                                         = $kubernetes::params::ca_crt,
  Optional[String] $ca_key                                         = $kubernetes::params::ca_key,
  Optional[String] $front_proxy_ca_crt                             = $kubernetes::params::front_proxy_ca_crt,
  Optional[String] $front_proxy_ca_key                             = $kubernetes::params::front_proxy_ca_key,
  Optional[String] $front_proxy_client_crt                         = $kubernetes::params::front_proxy_client_crt,
  Optional[String] $front_proxy_client_key                         = $kubernetes::params::front_proxy_client_key,
  Optional[String] $sa_key                                         = $kubernetes::params::sa_key,
  Optional[String] $sa_pub                                         = $kubernetes::params::sa_pub,
  Optional[String] $cni_network_provider                           = $kubernetes::params::cni_network_provider,
  Boolean $install_dashboard                                       = $kubernetes::params::install_dashboard,
  Boolean $taint_master                                            = $kubernetes::params::taint_master,
  String $node_label                                               = $kubernetes::params::node_label,

  )  inherits kubernetes::params {

  if $controller {
    if $worker {
      fail translate(('A node can not be both a controller and a node'))
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
    include kubernetes::config
    include kubernetes::service
    contain kubernetes::repos
    contain kubernetes::packages
    contain kubernetes::config
    contain kubernetes::service

    Class['kubernetes::repos']
      -> Class['kubernetes::packages']
      -> Class['kubernetes::config']
      -> Class['kubernetes::service']
  }
}
