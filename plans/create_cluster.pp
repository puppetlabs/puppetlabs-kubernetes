plan kubernetes::create_cluster(
  TargetSpec $controller,
  String[1] $k8s_version='1.2.0',
  String[1] $k8s_provider='vagrant',
  String[1] $num_nodes = '3'
) {
 
  # These get automagically set, right?
  #run_command($controller, "export $PT_os_family='linux'")
  #run_command($controller, "export $PT_k8s_version=${k8s_version}")
  run_command($controller, "export KUBERNETES_PROVIDER=${kubernetes_provider}")
  run_command($controller, "export NUM_NODES=${num_nodes}")
  file_upload("files/kube-config", "~/.kube/config", $controller) 
