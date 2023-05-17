# Class kubernetes kube_addons
# @param cni_network_preinstall
#   Defaults to undef
# @param cni_network_provider
#   Defaults to undef
# @param cni_pod_cidr
#   The overlay (internal) network range to use.
#   Defaults to undef. kube_tool sets this per cni provider.
# @param cni_provider
#   Defaults to undef
# @param cni_rbac_binding
#   The URL get the cni providers rbac rules. This is for use with Calico only.
#   Defaults to `undef`.
# @param install_dashboard
#   This is a bool that determines if the kubernetes dashboard is installed.
#   Defaults to false
# @param dashboard_version
#   The version of Kubernetes dashboard you want to install.
#   Defaults to 1.10.1
# @param dashboard_url
#   The URL to get the Kubernetes Dashboard yaml file.
#   Default is based on dashboard_version.
# @param kubernetes_version
#   The version of Kubernetes containers you want to install.
#   ie api server, Defaults to  1.10.2
# @param controller
#   This is a bool that sets the node as a Kubernetes controller
#   Defaults to false
# @param schedule_on_controller
#   A flag to remove the control plane role and allow pod scheduling on controllers
#   Defaults to true
# @param node_name
#   Name of the node. Defaults to a fact
# @param path
#   The path to be used when running kube* commands
#   Defaults to ['/usr/bin','/bin','/sbin','/usr/local/bin']
# @param env
#   The environment passed to kubectl commands.
#   Defaults to setting HOME and KUBECONFIG variables
#
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
        ensure  => file,
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
    exec { 'schedule on controller':
      command => "kubectl taint nodes ${node_name} node-role.kubernetes.io/master-",
      onlyif  => "kubectl describe nodes ${node_name} | tr -s ' ' | grep 'Taints: node-role.kubernetes.io/master:NoSchedule'",
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
