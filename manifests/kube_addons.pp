# Class kuberntes kube_addons
class kubernetes::kube_addons (

  Boolean $bootstrap_controller          = $kubernetes::bootstrap_controller,
  Optional[String]$cni_network_provider  = $kubernetes::cni_network_provider,
  Boolean $install_dashboard             = $kubernetes::install_dashboard,
  String $kubernetes_version             = $kubernetes::kubernetes_version,
  Boolean $controller                    = $kubernetes::controller,
  Boolean $taint_master                  = $kubernetes::taint_master,
  String $node_label                     = $kubernetes::node_label,
){

  Exec {
    path        => ['/usr/bin', '/bin'],
    environment => [ 'HOME=/root', 'KUBECONFIG=/root/admin.conf'],
    logoutput   => true,
    tries       => 5,
    try_sleep   => 5,
    }

  if $bootstrap_controller {

  $addon_dir = '/etc/kubernetes/addons'

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
  }

  if $controller {
    exec { 'Assign master role to controller':
      command => "kubectl label node ${node_label} node-role.kubernetes.io/master=",
      unless  => "kubectl describe nodes ${node_label} | tr -s ' ' | grep 'Roles: master'",
    }

    if $taint_master {

      exec { 'Checking for dns to be deployed':
        path      => ['/usr/bin', '/bin'],
        command   => 'kubectl get deploy -n kube-system kube-dns -o yaml | tr -s " " | grep "Deployment has minimum availability"',
        tries     => 50,
        try_sleep => 10,
        logoutput => true,
        onlyif    => 'kubectl get deploy -n kube-system kube-dns -o yaml | tr -s " " | grep "Deployment does not have minimum availability"', # lint:ignore:140chars
        }

      exec { 'Taint master node':
        command => "kubectl taint nodes ${node_label} key=value:NoSchedule",
        onlyif  => 'kubectl get nodes',
        unless  => "kubectl describe nodes ${node_label} | tr -s ' ' | grep 'Taints: key=value:NoSchedule'"
      }
    }
  }


  if $install_dashboard and $kubernetes_version =~ /1[.](8|9)[.]\d/ {
    exec { 'Install Kubernetes dashboard':
      command => 'kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml',
      onlyif  => 'kubectl get nodes',
      unless  => 'kubectl -n kube-system get pods | grep kubernetes-dashboard',
      }
    }
  if $install_dashboard and $kubernetes_version =~ /1[.](6|7)[.]\d/ {
    exec { 'Install Kubernetes dashboard':
      command => 'kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.6.3/src/deploy/kubernetes-dashboard.yaml',
      onlyif  => 'kubectl get nodes',
      unless  => 'kubectl -n kube-system get pods | grep kubernetes-dashboard',
      }
    }

}
