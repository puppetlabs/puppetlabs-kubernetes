# @summary Provisions machines
#
# Puppet Server Setup
#
# @example
#   kubernetes::puppetserver_setup
plan kubernetes::puppetserver_setup(
  Optional[String] $collection = 'puppet7-nightly'
) {
  $puppet_server =  get_targets('*').filter |$n| { $n.vars['role'] == 'controller' }

  # get facts
  $puppet_server_facts = facts($puppet_server[0])
  $platform = $puppet_server_facts['platform']

  # install puppet server
  run_task(
    'provision::install_puppetserver',
    $puppet_server,
    'install and configure server',
    { 'collection' => $collection, 'platform' => $platform }
  )
}
