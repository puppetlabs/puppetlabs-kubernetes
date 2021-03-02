plan kubernetes::puppetserver_setup(
) {
  $puppet_server =  get_targets('*').filter |$n| { $n.vars['role'] == 'controller' }
  $puppet_server_string = $puppet_server[0].name
  # install pe server
  run_task('provision::install_puppetserver', $puppet_server)
}


