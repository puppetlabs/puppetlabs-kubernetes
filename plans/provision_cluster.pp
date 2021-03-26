# @summary Provisions machines
#
# Provisions machines for integration testing
#
# @example
#   kubernetes::provision_integration
plan kubernetes::provision_cluster(
  Optional[String] $gcp_image = 'centos-7',
) {
  #provision server machine, set role
  run_task('provision::provision_service', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: controller')
  run_task('provision::provision_service', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: controller1')
  run_task('provision::provision_service', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: worker1')
  run_task('provision::provision_service', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: worker2')
  run_task('provision::provision_service', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: worker3')
}
