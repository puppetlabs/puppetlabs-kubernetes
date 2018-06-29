# Class kubernetes kube_addons
class kubernetes::kube_addons (

  Optional[String] $cni_network_provider_rbac = $kubernetes::cni_network_provider_rbac,
  Optional[String] $cni_network_provider      = $kubernetes::cni_network_provider,
  Optional[String] $calicoctl                 = $kubernetes::calicoctl,
  Boolean $install_dashboard                  = $kubernetes::install_dashboard,
  String $kubernetes_version                  = $kubernetes::kubernetes_version,
  Boolean $controller                         = $kubernetes::controller,
  Optional[Boolean] $schedule_on_controller   = $kubernetes::schedule_on_controller,
  String $node_label                          = $kubernetes::node_label,
){

  Exec {
    path        => ['/usr/bin', '/bin'],
    environment => [ 'HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
    logoutput   => true,
    tries       => 10,
    try_sleep   => 30,
    }

  Exec['Install cni network provider rbac']
    -> Exec['Install cni network provider']
    -> Exec['Install calicoctl pod for datastore']

  exec { 'Install cni network provider rbac':
    command => "kubectl apply -f ${cni_network_provider_rbac}",
    onlyif  => 'kubectl get nodes',
    unless  => 'kubectl get clusterroles | grep calico-node',
  }

  exec { 'Install cni network provider':
    command => "kubectl apply -f ${cni_network_provider}",
    onlyif  => 'kubectl get nodes',
    creates => '/etc/cni/net.d'
  }

  exec { 'Install calicoctl pod for datastore':
    command => "kubectl apply -f ${calicoctl}",
    unless  => 'kubectl get pods -n kube-system | grep calicoctl',
  }

  if $schedule_on_controller {

    exec { 'schedule on controller':
      command => "kubectl taint nodes ${node_label} node-role.kubernetes.io/master-",
      onlyif  => "kubectl describe nodes ${node_label} | tr -s ' ' | grep 'Taints: node-role.kubernetes.io/master:NoSchedule'"
    }
  }

  if $install_dashboard  {
    exec { 'Install Kubernetes dashboard':
      command => 'kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml',
      onlyif  => 'kubectl get nodes',
      unless  => 'kubectl -n kube-system get pods | grep kubernetes-dashboard',
      }
    }
}
