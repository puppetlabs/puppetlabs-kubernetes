# This class configures the RBAC roles fro Kubernetes 1.6

class kubernetes::cluster_roles (

  $bootstrap_controller = $kubernetes::bootstrap_controller,
  $kubernetes_version = $kubernetes::kubernetes_version,
){

  if $bootstrap_controller {

  Exec {
    path        => ['/usr/bin', '/bin'],
    environment => [ 'HOME=/root', 'KUBECONFIG=/root/admin.conf'],
    logoutput   => true,
    tries       => 5,
    try_sleep   => 5,
    }

  exec { 'Create kube bootstrap token':
    command     => 'kubectl create -f bootstraptoken.yaml',
    cwd         => '/etc/kubernetes/secrets',
    subscribe   => File['/etc/kubernetes/secrets/bootstraptoken.yaml'],
    refreshonly => true,
    require     => File['/etc/kubernetes/secrets/bootstraptoken.yaml'],
  }

  exec { 'Create kube proxy cluster bindings':
    command     => 'kubectl create -f clusterRoleBinding.yaml',
    cwd         => '/etc/kubernetes/manifests',
    subscribe   => File['/etc/kubernetes/manifests/clusterRoleBinding.yaml'],
    refreshonly => true,
    require     => File['/etc/kubernetes/manifests/clusterRoleBinding.yaml'],
    }

  if $kubernetes_version =~ /1[.]8[.]\d/ {

    exec { 'Create role biniding for system nodes':
      command => 'kubectl set subject clusterrolebinding system:node --group=system:nodes',
      }
    }
  }
}
