plan kubernetes::provision_gcp_abs(
  Optional[String] $gcp_image = 'centos-7-x86_64',
) {
  #provision server machine, set role
  run_task('provision::abs', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: master')
  run_task('provision::abs', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: controller')
  run_task('provision::abs', 'localhost',
    action => 'provision', platform => $gcp_image, vars => 'role: worker')
}
