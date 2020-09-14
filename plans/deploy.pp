# This plan is meant to create a deployment and a service on Kubernetes
# To run this plan you will have to enable the anonymous user access to you Kubernetes environment or add the necessary authentication parameters (token and ca_file for each task)
# Command to system:anonymous rights: kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
plan k8s::deploy(
  String[1] $name,
  String[1] $namespace,
  Integer $replicas,
  String[1] $image,
  Integer $container_port,
  String[1] $endpoint,
) {
  $responses=run_task('k8s::swagger_k8s_create_extensions_v1beta1_namespaced_deployment', 'localhost', namespace => $namespace, kube_api => $endpoint, apiversion=> 'extensions/v1beta1', kind => 'Deployment', metadata => "{'name' => '${name}'; 'labels' => { 'app' => '${name}' } }", spec => "{ 'replicas' => ${replicas}; 'selector' => {'matchLabels' => {'app' => '${name}' }}; 'template' => { 'metadata' => {'labels'=>{ 'app' => '${name}' }} ;  'spec' => { 'containers' => [ { 'name' => '${name}'; 'image' => '${image}'; 'ports' => [ {'containerPort' => ${container_port} }] }  ] } } }")

  notice($responses.first)

  $service= run_task('k8s::swagger_k8s_create_core_v1_namespaced_service','localhost', namespace => $namespace, kube_api => $endpoint, apiversion => 'v1', kind => 'Service', metadata => "{'name' => '${name}'}", spec => "{'selector'=>{'app'=>'${name}'};'type'=>'ClusterIP';'ports'=>[{'protocol'=>'TCP';'port'=>${container_port}}]}" )

  notice($service)
}
