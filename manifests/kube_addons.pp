# Class kuberntes Kube addonsv v
class kubernetes::kube_addons (

  $bootstrap_controller = $kubernetes::bootstrap_controller,
  $cni_network_provider = $kubernetes::cni_network_provider,
  $install_dashboard = $kubernetes::install_dashboard,

){

  if $bootstrap_controller {

  $addon_dir = '/etc/kubernetes/addons'

  Exec {
    path        => ['/usr/bin', '/bin'],
    environment => [ 'HOME=/root', 'KUBECONFIG=/root/admin.conf'],
    logoutput   => true,
    tries       => 5,
    try_sleep   => 5,
    }

  exec { 'Install cni network provider':
    command => "kubectl apply -f ${cni_network_provider}",
    onlyif  => 'kubectl get nodes',
    }

  exec { 'Create kube proxy service account':
    command     => 'kubectl create -f kube-proxy-sa.yaml',
    cwd         => $addon_dir,
    subscribe   => File['/etc/kubernetes/addons/kube-proxy-sa.yaml'],
    refreshonly => true,
    require     => Exec['Install cni network provider'],
  }

  exec { 'Create kube proxy ConfigMap':
    command     => 'kubectl create -f kube-proxy.yaml',
    cwd         => $addon_dir,
    subscribe   => File['/etc/kubernetes/addons/kube-proxy.yaml'],
    refreshonly => true,
    require     => Exec['Create kube proxy service account'],
  }

  exec { 'Create kube proxy daemonset':
    command     => 'kubectl create -f kube-proxy-daemonset.yaml',
    cwd         => $addon_dir,
    subscribe   => File['/etc/kubernetes/addons/kube-proxy-daemonset.yaml'],
    refreshonly => true,
    require     => Exec['Create kube proxy ConfigMap'],
  }

  exec { 'Create kube dns service account':
    command     => 'kubectl create -f kube-dns-sa.yaml',
    cwd         => $addon_dir,
    subscribe   => File['/etc/kubernetes/addons/kube-dns-sa.yaml'],
    refreshonly => true,
    }

  exec { 'Create kube dns service':
    command     => 'kubectl create -f kube-dns-service.yaml',
    cwd         => $addon_dir,
    subscribe   => File['/etc/kubernetes/addons/kube-dns-service.yaml'],
    refreshonly => true,
    require     => Exec['Create kube dns service account'],
    }

  exec { 'Create kube dns deployment':
    command     => 'kubectl create -f kube-dns-deployment.yaml',
    cwd         => $addon_dir,
    subscribe   => File['/etc/kubernetes/addons/kube-dns-deployment.yaml'],
    refreshonly => true,
    require     => Exec['Create kube dns service account'],
    }

  if $install_dashboard {
    exec { 'Install Kubernetes dashbaord':
      command => 'kubectl create -f https://git.io/kube-dashboard',
      onlyif  => 'kubectl get nodes',
      unless  => 'kubectl -n kube-system get pods | grep kubernetes-dashboard',
      }
    }
  }
}
