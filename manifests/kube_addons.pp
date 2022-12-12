# Class kubernetes kube_addons
class kubernetes::kube_addons (

  Optional[String] $cni_network_preinstall  = $kubernetes::cni_network_preinstall,
  Optional[String] $cni_network_provider    = $kubernetes::cni_network_provider,
  Optional[String] $cni_pod_cidr            = $kubernetes::cni_pod_cidr,
  Optional[String] $cni_provider            = $kubernetes::cni_provider,
  Optional[String] $cni_rbac_binding        = $kubernetes::cni_rbac_binding,
  Boolean $install_dashboard                = $kubernetes::install_dashboard,
  String $dashboard_version                 = $kubernetes::dashboard_version,
  String $dashboard_url                     = $kubernetes::dashboard_url,
  String $kubernetes_version                = $kubernetes::kubernetes_version,
  Boolean $controller                       = $kubernetes::controller,
  Optional[Boolean] $schedule_on_controller = $kubernetes::schedule_on_controller,
  Stdlib::Fqdn $node_name                   = $kubernetes::node_name,
  Array $path                               = $kubernetes::default_path,
  Optional[Array] $env                      = $kubernetes::environment,
) {
  Exec {
    path        => $path,
    environment => $env,
    logoutput   => true,
    tries       => 10,
    try_sleep   => 30,
  }

  $exec_onlyif = 'kubectl get nodes'

  if $cni_rbac_binding {
    exec { 'Install calico rbac bindings':
      environment => $env,
      command     => ['kubectl', 'apply', '-f', $cni_rbac_binding],
      onlyif      => $exec_onlyif,
      unless      => 'kubectl get clusterrole | grep calico',
    }
  }

  if $cni_network_provider {
    if $cni_provider == 'calico-tigera' {
      if $cni_network_preinstall {
        exec { 'Install cni network (preinstall)':
          command     => ['kubectl', 'apply', '-f', $cni_network_preinstall],
          onlyif      => $exec_onlyif,
          unless      => 'kubectl -n tigera-operator get deployments | egrep "^tigera-operator"',
          environment => $env,
          before      => Exec['Install cni network provider'],
        }
      }
      file { '/etc/kubernetes/calico-installation.yaml':
        ensure  => 'present',
        group   => 'root',
        mode    => '0400',
        owner   => 'root',
        replace => false,
        source  => $cni_network_provider,
      } -> file_line { 'Configure calico ipPools.cidr':
        ensure   => present,
        path     => '/etc/kubernetes/calico-installation.yaml',
        match    => '      cidr:',
        line     => "      cidr: ${cni_pod_cidr}",
        multiple => false,
        replace  => true,
      } -> exec { 'Install cni network provider':
        command     => 'kubectl apply -f /etc/kubernetes/calico-installation.yaml',
        onlyif      => $exec_onlyif,
        unless      => 'kubectl -n calico-system get daemonset | egrep "^calico-node"',
        environment => $env,
      }
    } else {
      exec { 'Install cni network provider':
        command     => ['kubectl', 'apply', '-f', $cni_network_provider],
        onlyif      => $exec_onlyif,
        unless      => 'kubectl -n kube-system get daemonset | egrep "(flannel|weave|calico-node|cilium)"',
        environment => $env,
      }
    }
  }

  if $schedule_on_controller {
    $safe_node_name = shell_escape($node_name)
    exec { 'schedule on controller':
      command => "kubectl taint nodes ${safe_node_name} node-role.kubernetes.io/master-",
      onlyif  => "kubectl describe nodes ${safe_node_name} | tr -s ' ' | grep 'Taints: node-role.kubernetes.io/master:NoSchedule'",
    }
  }

  if $install_dashboard {
    exec { 'Install Kubernetes dashboard':
      command     => ['kubectl', 'apply', '-f', $dashboard_url],
      onlyif      => $exec_onlyif,
      unless      => [
        'kubectl get pods --field-selector="status.phase=Running" -n kubernetes-dashboard | grep kubernetes-dashboard-',
        'kubectl get pods --field-selector="status.phase=Running" -n kube-system | grep kubernetes-dashboard-',
      ],
      environment => $env,
    }
  }
}
