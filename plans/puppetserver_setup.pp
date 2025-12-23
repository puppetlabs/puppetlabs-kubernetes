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

  # Ensure Java 17 is used for Puppet Server 8 on supported platforms
  # run_task(
 #   'kubernetes::ensure_java17_for_puppetserver',
 #   $puppet_server,
 #   'ensure java17 for puppetserver service',
 #   { 'collection' => $collection, 'platform' => $platform }
 # )

  # Restart Puppet Server to pick up JAVA_HOME overrides
 # run_command('systemctl daemon-reload', $puppet_server)
 # run_command('systemctl restart puppetserver', $puppet_server)
 # run_command('systemctl is-active puppetserver', $puppet_server)
}
