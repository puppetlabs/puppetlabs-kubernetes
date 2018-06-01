# This class configures the RBAC roles for Kubernetes 1.10.x

class kubernetes::cluster_roles (

  String $kubernetes_version  = $kubernetes::kubernetes_version,
  Optional[String] $controller_address = $kubernetes::controller_address,
  Optional[Boolean] $controller = $kubernetes::controller,
  Optional[Boolean] $worker = $kubernetes::worker,
  Optional[String] $etcd_ip = $kubernetes::etcd_ip,
  Optional[String] $etcd_initial_cluster = $kubernetes::etcd_initial_cluster,
  String $node_label = $kubernetes::node_label,
  String $etcd_ca_key = $kubernetes::etcd_ca_key,
  String $etcd_ca_crt = $kubernetes::etcd_ca_crt,
  String $etcdclient_key = $kubernetes::etcdclient_key,
  String $etcdclient_crt = $kubernetes::etcdclient_crt,
  String $kube_api_advertise_address = $kubernetes::kube_api_advertise_address,
  Integer $api_server_count = $kubernetes::api_server_count,
  String $cni_pod_cidr = $kubernetes::cni_pod_cidr,
  String $token = $kubernetes::token,
  String $discovery_token_hash = $kubernetes::discovery_token_hash,

){
  $path = ['/usr/bin','/bin','/sbin','/usr/local/bin']
  $env = ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf']

  if $controller {
    kubernetes::kubeadm_init { $node_label:
      config     => '/etc/kubernetes/config.yaml',
      path       => $path,
      env        => $env,
      node_label => $node_label,
      }
    }

  if $worker {
    kubernetes::kubeadm_join { $node_label:
      path               => $path,
      env                => $env,
      controller_address => $controller_address,
      token              => $token,
      ca_cert_hash       => $discovery_token_hash,
      cri_socket         => '/run/containerd/containerd.sock',
      node_label         => $node_label,
      }
    }
}
