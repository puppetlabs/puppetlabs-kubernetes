# Version 2.0.2

Fixes issue with cgroup mismatch on docker PR #109

ignores docker warning ine prelifght checks when using containerd PR #109

# Version 2.0.1

Changes default runtime to docker

# Version 2.0.0

Architectural change to use kubeadm project to bootstrap kubernetes clusters.

Updates to kubetool and params to reflect this change. See the README.md in this repo and consult the official kubeadm documenation [here](https://kubernetes.io/docs/setup/independent/)

# Version 1.1.0

Add parameters for networking

Minor bug fixes

Full list of PR's available at [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/1?closed=1)


# Version 1.0.3

Change exec path for controller PR #57

Fix gpg key for docker apt repo PR #58

Fix in kubetool for weave cni provider URL PR #63


# Version 1.0.2
Hotfix for kubelet downgrading cni in the rhel family


# Version 1.0.1
Support for weave and flannel

EPEL module removed as dependency

Added `$apiserver_extra_arguments` PR #47

Added support for PDK

Added support for stdlib 4.24.0

Updated kubetool to include CNI information in hiera (see README)


# Version 1.0.0
Officially supported version of puppetlabs-kubernetes


# Version 0.2.0
Supports Kubernetes up to 1.9.x

Adds support for cri-containerd runtime

Provides additional os and runtime switches for Kubetool


# Version 0.1.3

Provide cli switches for kubetool, and add Dockerfile

# Version 0.1.2


Supports Kubernetes up to 1.8.x

# Version 0.1.1

Hotfix for kubeproxy

# Version 0.1.0

First release

Supports Kubernetes 1.6 - 1.7.5

