#!/bin/sh

# Install kubernetes
curl https://get.k8s.io > kubernetes_install.sh
./kubernetes_install.sh

# Install kubectl
curl https://storage.googleapis.com/kubernetes-release/release/v$PT_k8s_version/bin/$PT_os_family/amd64/kubectl
export KUBECONFIG=$HOME/.kube/config
