# @summary Provisions machines
#
# Puppet Server Setup
#
# @example
#   kubernetes::puppetserver_setup
plan kubernetes::puppetserver_setup(
  Optional[String] $collection = 'puppet7-nightly'
) {
  # Falls back to the 'controller' role so single-node-primary inventories (controller
  # doubles as both Puppet primary and Kubernetes control-plane) keep working unchanged;
  # tag a node 'puppetserver' instead when the primary is a separate, dedicated node
  # (e.g. to run a different OS/Puppet-collection than the Kubernetes cluster nodes).
  $puppet_server = get_targets('*').filter |$n| { $n.vars['role'] == 'puppetserver' }
  $puppet_server_target = if $puppet_server.empty {
    get_targets('*').filter |$n| { $n.vars['role'] == 'controller' }
  } else {
    $puppet_server
  }

  # get facts
  $puppet_server_facts = facts($puppet_server_target[0])
  $platform = $puppet_server_facts['platform']

  # install puppet server
  run_task(
    'provision::install_puppetserver',
    $puppet_server_target,
    'install and configure server',
    { 'collection' => $collection, 'platform' => $platform }
  )
}
