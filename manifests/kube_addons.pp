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
    $binding_command = ['kubectl', 'apply', '-f', $cni_rbac_binding]
    $binding_unless = 'kubectl get clusterrole | grep calico'

    exec { 'Install calico rbac bindings':
      environment => $env,
      command     => $binding_command,
      onlyif      => $exec_onlyif,
      unless      => $binding_unless,
    }
  }

  if $cni_network_provider {
    if $cni_provider == 'calico-tigera' {
      if $cni_network_preinstall {
        $preinstall_command = ['kubectl', 'apply', '-f', $cni_network_preinstall]
        $preinstall_unless = 'kubectl -n tigera-operator get deployments | egrep "^tigera-operator"'

        exec { 'Install cni network (preinstall)':
          command     => $preinstall_command,
          onlyif      => $exec_onlyif,
          unless      => $preinstall_unless,
          environment => $env,
          before      => Exec['Install cni network provider'],
        }
      }
      # Removing Calico_installation_path variable as it doesnt seem to apport any extra value here.
      $calico_installation_path = '/etc/kubernetes/calico-installation.yaml'
      $path_command = 'kubectl apply -f /etc/kubernetes/calico-installation.yaml'
      $path_unless = 'kubectl -n calico-system get daemonset | egrep "^calico-node"'

      file { $calico_installation_path:
        ensure  => 'present',
        group   => 'root',
        mode    => '0400',
        owner   => 'root',
        replace => false,
        source  => $cni_network_provider,
      } -> file_line { 'Configure calico ipPools.cidr':
        ensure   => present,
        path     => $calico_installation_path,
        match    => '      cidr:',
        line     => "      cidr: ${cni_pod_cidr}",
        multiple => false,
        replace  => true,
      } -> exec { 'Install cni network provider':
        command     => $path_command,
        onlyif      => $exec_onlyif,
        unless      => $path_unless,
        environment => $env,
      }
    } else {
      $provider_command = ['kubectl', 'apply', '-f', $cni_network_provider]
      $provider_unless = 'kubectl -n kube-system get daemonset | egrep "(flannel|weave|calico-node|cilium)"'

      exec { 'Install cni network provider':
        command     => $provider_command,
        onlyif      => $exec_onlyif,
        unless      => $provider_unless,
        environment => $env,
      }
    }
  }

  if $schedule_on_controller {
    $schedule_command = ['kubectl', 'taint', 'nodes', $node_name, 'node-role.kubernetes.io/master-']
    $schedule_onlyif = "kubectl describe nodes ${node_name} | tr -s ' ' | grep 'Taints: node-role.kubernetes.io/master:NoSchedule'"

    exec { 'schedule on controller':
      command => $schedule_command,
      onlyif  => $schedule_onlyif,
    }
  }

  if $install_dashboard {
    $dashboard_command = ['kubectl', 'apply', '-f', $dashboard_url]
    $dashboard_unless = [
      'kubectl get pods --field-selector="status.phase=Running" -n kubernetes-dashboard | grep kubernetes-dashboard-',
      'kubectl get pods --field-selector="status.phase=Running" -n kube-system | grep kubernetes-dashboard-'
    ]

    exec { 'Install Kubernetes dashboard':
      command     => $dashboard_command,
      onlyif      => $exec_onlyif,
      unless      => $dashboard_unless,
      environment => $env,
    }
  }
}
