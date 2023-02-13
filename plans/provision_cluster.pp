# @summary Provisions machines
#
# Provisions machines for integration testing
#
# @example
#   kubernetes::provision_cluster
plan kubernetes::provision_cluster(
  Optional[String] $image_type = 'centos-7',
  Optional[String] $provision_type = 'provision_service',
) {
  #provision server machine, set role
  run_task("provision::${provision_type}", 'localhost', action => 'provision', platform => $image_type, vars => 'role: controller')
  run_task("provision::${provision_type}", 'localhost', action => 'provision', platform => $image_type, vars => 'role: worker1')
  run_task("provision::${provision_type}", 'localhost', action => 'provision', platform => $image_type, vars => 'role: worker2')
}
