# Class kubernetes kube_addons
class kubernetes::kube_addons (

  Optional[String] $cni_network_provider     = $kubernetes::cni_network_provider,
  Optional[String] $cni_rbac_binding         = $kubernetes::cni_rbac_binding,
  Boolean $install_dashboard                 = $kubernetes::install_dashboard,
  String $kubernetes_version                 = $kubernetes::kubernetes_version,
  Boolean $controller                        = $kubernetes::controller,
  Optional[Boolean] $schedule_on_controller  = $kubernetes::schedule_on_controller,
  String $node_label                         = $kubernetes::node_label,
){

  Exec {
    path        => ['/usr/bin', '/bin'],
    environment => [ 'HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
    logoutput   => true,
    tries       => 10,
    try_sleep   => 30,
    }

  if $cni_rbac_binding {
    exec { 'Install calico rbac bindings':
    command => "kubectl apply -f ${cni_rbac_binding}",
    onlyif  => 'kubectl get nodes',
    unless  => 'kubectl get clusterrole | grep calico'
    }
  }

  exec { 'Install cni network provider':
    command => "kubectl apply -f ${cni_network_provider}",
    onlyif  => 'kubectl get nodes',
    creates => '/etc/cni/net.d'
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
