#!/bin/bash

endpoint=${KUBE_API:-https://localhost:8080}
token=$KUBE_TOKEN

#List namespaces
bolt task run --nodes localhost k8s::swagger_k8s_list_core_v1_namespace kube_api=$endpoint token=$token

#Create a pod
#bolt task run --nodes localhost k8s::swagger_k8s_create_core_v1_namespaced_pod kube_api=$endpoint apiversion="v1" kind="Pod" spec="{ 'containers' => [{'name'=>'nginx'; 'image'=>'nginx'; 'ports' => [{'containerPort'=>80}]}] }" metadata="{ 'name' => 'nginx-test' }" namespace="default" token=$token

#Create a deployment
#bolt task run --nodes localhost k8s::swagger_k8s_create_extensions_v1beta1_namespaced_deployment kube_api=$endpoint body="$PWD/assets/nginx_deployment.json" namespace="default" token=$token

#Create a service
#bolt task run --nodes localhost k8s::swagger_k8s_create_core_v1_namespaced_service kube_api=$endpoint token=$token body="$PWD/assets/nginx_service.yaml" namespace="default"

#Delete a service
#bolt task run --nodes localhost k8s::swagger_k8s_delete_core_v1_namespaced_service kube_api=$endpoint token=$token metadata="{'name'=>'nginxtestservice'}" namespace="default" name="nginxtestservice"