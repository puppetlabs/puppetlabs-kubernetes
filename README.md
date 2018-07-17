[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-kubernetes.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-kubernetes)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppetlabs/kubernetes.svg)](https://forge.puppetlabs.com/puppetlabs/kubernetes)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppetlabs/kubernetes.svg)](https://forge.puppetlabs.com/puppetlabs/kubernetes)

# Kubernetes

#### Table of Contents

1. [Description](#description)
2. [Installing the Module](#install)
3. [Setup - The basics of getting started with kubernetes](#setup)
   * [Generate the module configuration](#generate-the-module-configuration)
   * [Add the OS and hostname yaml files to Hiera](#add-the-`{$OS}.yaml`-and-`{$hostname}.yaml`-files-to-Hiera)
   * [Configure your node](#configure-your-node)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
   * [Classes](#classes)
   * [Defined types](#definedtypes)
   * [Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The Puppet kubernetes module installs and configures the [Kubernetes](https://Kubernetes.io/) system which arranges containers into logical units to improve management and discovery.

## Description

This module installs and configures [Kubernetes](https://kubernetes.io/). Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications. For efficient management and discovery, containers that make up an application are grouped into logical units.

To bootstrap a kubernetes cluster in a secure and extensible way, this module uses the [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) toolkit.


## Install

To use this module, add this declaration to your Puppetfile:

```
mod 'puppetlabs-kubernetes', '2.0.2'
```

To manually install this module using the Puppet module tool, run:

```
puppet module install puppetlabs-kubernetes --version 2.0.2
```

## Setup

Included in this module is [kubetool](tooling/kube_tool.rb), a configuration tool which auto generates the security
parameters, the discovery token hash, and other configurations for your Kubernetes
cluster into a Hiera file. To simplify installation and use, the tool is available as a Docker
image.

### Generate the module configuration

If Docker is not installed on your workstation, install it from [here](https://www.docker.com/community-edition).

The kubetool docker image takes each parameter as an environment variable. 

**Note**: The version of kubetool you use must match the version of the module on the Puppet Forge. For example, if using the module version 1.0.0, use `puppet/kubetool:1.0.0`. 

To output a yaml file into your working directory that corresponds to the operating system you want Kubernetes to run on, and for each controller node, run either of these `docker run` commands:

```
docker run --rm -v $(pwd):/mnt --env-file .env puppet/kubetool:{$module_version}
```

The docker run command above includes a .env file included in the tooling folder of this repo.

```
docker run --rm -v $(pwd):/mnt -e OS=debian -e VERSION=1.10.2 -e CONTAINER_RUNTIME=docker -e CNI_PROVIDER=weave -e ETCD_INITIAL_CLUSTER=kube-master:172.17.10.101,kube-replica-master-01:172.17.10.210,kube-replica-master-02:172.17.10.220 -e ETCD_IP="%{::ipaddress_eth1}" -e KUBE_API_ADVERTISE_ADDRESS="%{::ipaddress_eth1}" -e INSTALL_DASHBOARD=true puppet/kubetool:{$module-version}
```

The parameters are:

* `OS`: The operating system kubernetes runs on.
* `VERSION`: The version of kubernetes to deploy.
* `CONTAINER_RUNTIME`: The container runtime kubernetes uses. Set this value to `docker` or `cri_containerd`.
* `CNI_PROVIDER` : The CNI network to install. Set this value to `weave` or `flannel`.
* `ETCD_INITIAL_CLUSTER`: The server hostnames and IPs in the form of `hostname:ip`. When in production, include three, five, or seven nodes for etcd.
* `ETCD_IP`: The IP each etcd member listens on. We recommend passing the fact for the interface to be used by the cluster.
* `KUBE_API_ADVERTISE_ADDRESS`: The IP each etcd/apiserver instance uses on each controller. We recommend passing the fact for the interface to be used by the cluster.
* `INSTALL_DASHBOARD`: A boolean which specifies whether to install the dashboard.

The kubetool creates:

* A yaml file that corresponds to the operating system specified by the `OS` paramater. To view the file contents, run `cat Debian.yaml` for a Debian system, or run `cat RedHat.yaml` for RedHat. 

The yaml files produced for each member of the etcd cluster contain certificate information to bootstrap an initial etcd cluster. Ensure these are also placed in your hieradata directory at the node level. 

* A discovery token hash and encoded values required by Kubernetes. To regenerate the values, including certificates and tokens, run the `kubetool` command again.

### Add the `{$OS}.yaml` and `{$hostname}.yaml` files to Hiera

Add the `{$OS}.yaml` file to the same [control repo](https://puppet.com/docs/pe/2017.3/code_management/control_repo.html) where your [Hiera](https://docs.puppet.com/hiera/) data is, usually the `data` directory. By leveraging location facts, such as the [pp_datacenter](https://puppet.com/docs/puppet/5.0/ssl_attributes_extensions.html#puppet-specific-registered-ids) [trusted fact](https://puppet.com/docs/puppet/5.0/lang_facts_and_builtin_vars.html#trusted-facts), each cluster can be allocated its own configuration.

### Configure your node

After the `{$OS}.yaml` and `{$hostname}.yaml` files have been added to the Hiera directory on your Puppet server, configure your node as the controller or worker. 

A controller node contains the control plane and `etcd`. In a production cluster you should have three, five, or seven controllers. A worker node runs your applications. You can add as many worker nodes as Kubernetes can handle. For information about nodes in Kubernetes, see the [Kubernetes docs](https://kubernetes.io/docs/concepts/architecture/nodes/#what-is-a-node).

**Note**: A node can not be a controller and a worker. It must be one or the other.

To make a node a controller, add the following code to the manifest:

```puppet
class {'kubernetes':
  controller => true,
}
```

To make a node a worker, add the following code to the manifest:

```puppet
class {'kubernetes':
  worker => true,
}
```

## Reference

### Classes

#### Public classes

* kubernetes
* kubernetes::params

#### Private classes

* kubernetes::cluster_nodes
* kubernetes::config
* kubernetes::kube_addons
* kubernetes::packages
* kubernetes::repos
* kubernetes::service

### Defined types

* kubernetes::kubeadm_init
* kubernetes::kubeadm_join

### Parameters

The following parameters are available in the `kubernetes` class.

#### `kubernetes_version`

The version of the Kubernetes containers to install.

Defaults to  `1.10.2`.

#### `kubernetes_package_version`

The version the Kubernetes OS packages to install, such as `kubectl` and `kubelet`.

Defaults to `1.10.2`.

#### `cni_network_provider`

The URL to get the cni providers yaml file. 

Defaults to `undef`. `kube_tool` sets this value.

#### `container_runtime`

Specifies the runtime that the Kubernetes cluster uses.

Valid values are `cri_containerd` or `docker`.

Defaults to `docker`.

#### `controller`

Specifies whether to set the node as a Kubernetes controller.

Valid values are `true`, `false`.

Defaults to `false`.

#### `worker`

Defaults to `false`.

Specifies whether to set the node as a Kubernetes worker.

Valid values are true, false.

Defaults to false.

#### `kube_api_advertise_address`

The IP address you want exposed by the API server.

A hiera example is `kubernetes::kube_api_advertise_address:"%{::ipaddress_enp0s8}"`.

Defaults to `undef`.

#### `apiserver_extra_arguments`

A string array of extra arguments passed to the api server.

Defaults to `[]`.

#### `apiserver_cert_extra_sans`

A string array of Subhect Alternative Names for the api server certificates.

Defaults to `[]`.

#### `etcd_version`

The version of etcd to use.

Defaults to `3.1.12`.

#### `etcd_ip`

The IP address you want etcd to use for communications.

A hiera is `kubernetes::etcd_ip:"%{::ipaddress_enp0s8}"`.

Defaults to `undef`.

#### `etcd_initial_cluster`

A string to inform etcd how many nodes are in the cluster.

A hiera example is `kubernetes::etcd_initial_cluster: kube-master:172.17.10.101,kube-replica-master-01:172.17.10.210,kube-replica-master-02:172.17.10.220`.

Defaults to `undef`.

#### `etcd_peers`

Specifies how etcd lists the peers to connect to into the cluster.

A hiera example is `kubernetes::etcd_peers`: 
* 172.17.10.101
* 172.17.10.102
* 172.17.10.103   

Defaults to `undef`

#### `etcd_ca_key`

The ca certificate key data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcd_ca_crt`

The ca certificate data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcdclient_key`

The client certificate key data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcdclient_crt`

The client certificate data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcdserver_key`

The server certificate key data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcdserver_crt`

The server certificate data for the etcd cluster . This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcdpeer_crt`

The peer certificate data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `etcdpeer_key`

The peer certificate key data for the etcd cluster. This value must be passed as string not as a file.

Defaults to `undef`.

#### `kubernetes_ca_crt`

The clusters ca certificate. Must be passed as a string not a file.

Defaults to undef

#### `kubernetes_ca_key`

The clusters ca key. Must be passed as a string not a file.

Defaults to undef

#### `sa_key`

The key for the service account. This value must be a certificate value and not a file.

Defaults to `undef`.

#### `sa_pub`

The public key for the service account. This value must be a certificate value and not a file.

Defaults to `undef`.

#### `token`

The string used to join nodes to the cluster. This value must be in the form of `[a-z0-9]{6}.[a-z0-9]{16}`.

Defaults to `undef`.

#### `discovery_token_hash`

The string used to validate to the root CA public key when joining a cluster. This value is created by `kubetool`.

Defaults to `undef`

#### `install_dashboard`

Specifies whether the kubernetes dashboard is installed.

Valid values are `true`, `false`.

Defaults to `false`.

#### `schedule_on_controller`

Specifies whether to remove the master role and allow pod scheduling on controllers.

Valid values are `true`, `false`.

Defaults to `false`.

#### `node_label`

Allows the user to override the label of a node.

Defaults to `hostname`.

#### `docker_version`

Specifies the version of the docker runtime you want to install.

Defaults to `17.03.0.ce-1.el7.centos` on RedHat.
Defaults to `17.03.0~ce-0~ubuntu-xenial` on Debian.

#### `containerd_version`

Specifies the version of the containerd runtime the module installs.

Defaults to `1.1.0`.

#### `cni_pod_cidr`

Specifies the overlay (internal) network range to use. This value is set by `kube_tool` per cni provider.

Defaults to `undef`.

#### `service_cidr`

The IP address range for service VIPs.

Defaults to `10.96.0.0/12`.

#### `controller_address`

The IP address and port for the controller the worker node joins. For example, `172.17.10.101:6443`. 

Defaults to `undef`. This value is set by `kube_tool`. 

#### `cloud_provider`

The name of the cloud provider configured in `/etc/kubernetes/cloud-config`.

**Note**: This file is not managed within this module and must be present before bootstrapping the kubernetes controller.

Defaults to `undef`.


## Limitations

This module supports [Kubernetes 1.10.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v160) and above.

The default container runtime for this module is [Docker]. This is considered stable, and the only officially supported runtime. Advanced [Kubernetes] users can use cri_containerd, however this requires a greater knowledge of [Kubernetes], spefically when running applications in a HA cluster. 

In order to run a HA cluster and access your applications, an external load balancer is required in front of your cluster. Setting this up is beyond the scope of this module, and it's recommended that users consult the [Kubernetes] documentation on load balancing in front of a cluster [here](https://kubernetes-v1-4.github.io/docs/user-guide/load-balancer/).

This module supports only Puppet 4 and above.

This module has been tested on the following OS

RedHat 7.x
CentOS 7.x
Ubuntu 16.04

## Development

If you would like to contribute to this module please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/CONTRIBUTING.md).
