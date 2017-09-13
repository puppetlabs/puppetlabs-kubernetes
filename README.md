# Kubernetes

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with kubernetes](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kubernetes](#beginning-with-kubernetes)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

The Puppet kubernetes module installs and configures the [Kubernetes](https://Kubernetes.io/) system which arranges containers into logical units to improve management and discovery.

## Description

This module lets you use Puppet to install and configure Kubernetes for automating deployment, scaling, and management of containerized applications.

## Setup

### Setup Requirements

#### Installing the Cloudflare PKI Toolkit (CFSSL)

To install CFSSL, follow these [instructions](https://github.com/cloudflare/cfssl).
Please note CFSSL need to be in your `$PATH` for the kube_tool to gernerate your ssl certificates.

#### Installing the kubernetes module

To install the kubernetes module, run `puppet module install puppetlabs-kubernetes --version 0.1.0`. We recommend that you install the kubernetes module onto a local machine and not a Puppet server.

Change to the root directory of the module and run the `bundle install` command.

To help with the setup requirements, we have included `kube_tool` to automatically generate the security parameters, the bootstrap token, and additional cluster configurations into a kubernetes.yaml file for your cluster. You can manually configure the parameters for the kubernetes module in the [init.pp](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/manifests/init.pp) file.

To run `kube_tool`, change to the [tools](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/master/tooling) directory.

To view the kube_tool help menu, run the `./kube_tool.rb` command to display:

```puppet

Commands:
  kube_tool.rb build_heira FQDN, IP, BOOTSTRAP_CONTROLLER_IP, ETCD_INITIAL_CLUSTER, ETCD_IP, KUBE_API_ADVERTISE_ADDRESS, INSTALL_DASHBOARD  # Pass the cluster params to build your hiera configuration
  kube_tool.rb help [COMMAND]                                                                                                               # Describe available commands or one specific command
```

This is an example of how to generate a kubernetes.yaml file for your cluster:

```puppet

./kube_tool.rb build_heira kubernetes 172.17.10.101 172.17.10.101 "etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380"  "%{::ipaddress_enp0s8}"  "%{::ipaddress_enp0s8}" true
```

The parameters are:

* `FQDN`: the cluster fqdn.
* `BOOTSTRAP_CONTROLLER_IP`: the ip address of the controller that is used to create cluster role bindings, the kube dns, and the Kubernetes dashboard.
* `ETCD_INITIAL_CLUSTER`: the server addresses. When in production, include 3, 5, or 7 nodes for etcd. 
* `ETCD_IP` and `ETCD_IP KUBE_API_ADVERTISE_ADDRESS`: we recommend passing the fact for the interface to be used by the cluster. 
* `INSTALL_DASHBOARD`: a boolean value which indicates whether to install the dashboard. 

To view the base64 encoded values and the bootstrap token required for kubernetes, run the `cat` command on the kubernetes.yaml file. If you run the `cat` command again, all of the values are regenerated.

Add the kubernetes.yaml file to your control repo or version control application and ship it via your cd process to your Puppet server. [more info required for this process]


### Begininning with kubernetes

To begin with the kubernetes module, add three parameters to your node:

* [bootstrap controller](###bootstrap-controller)
* [controller](###controller)
* [worker](###worker)

### Bootstrap Controller

To add cluster add-ons (kube dns, cluster role bindings, etc.), the cluster will use the bootstrap controller. Once the cluster is bootstrapped the controller becomes a standard controller.

To configure a bootstrap controller:

```puppet

class {'kubernetes':
  controller           => true,
  bootstrap_controller => true,
  }
```

### Controller

The controller contains the control plane and etcd which is the Kubernetes’ backing store for all cluster data. In a production cluster we recommend having 3, 5, or 7 controllers.

To configure a controller:

```puppet

class {'kubernetes':
  controller => true,
  }
```

### Worker

The worker node runs the application code in the cluster and you can configure as many nodes as [Kubernetes](https://kubernetes.io/docs/concepts/architecture/nodes/#what-is-a-node) supports. A node can be a controller or a worker, but not both.

To configure a worker node:

```puppet

class {'kubernetes':
  woker => true,
  }
```

## Usage

This section is where you describe how to customize, configure, and do the fancy stuff with your module here. It's especially helpful if you include usage examples and code samples for doing things with your module.

## Reference

The Reference section is the other section (besides Usage) that contains the bulk of the README writing. Modules can contain a variety of elements: classes, defined types, types, facts, and functions. To help the reader stay on track, organize a sort of mini-ToC with links to subsections detailing each element.

## Limitations

The kubernetes module supports:

* Puppet 4 and above
* [Kubernetes 1.6](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v160) and above

## Development

If you would like to contribute to this module please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/CONTRIBUTING.md)
