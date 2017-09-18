# Kubernetes

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with kubernetes](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kubernetes](#beginning-with-kubernetes)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

The Puppet kubernetes module installs and configures the [Kubernetes](https://Kubernetes.io/) system which arranges containers into logical units to improve management and discovery.

## Description

This module installs and configures [Kubernetes](https://kubernetes.io/). Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

It groups containers that make up an application into logical units for easy management and discovery.

## Setup

### Setup Requirements

The included configuration tool, `kube_tools` auto generates all the security parameters, the bootstrap token, and other configurations for your cluster into a file.

First install the module `puppet module install puppetlabs-kubernetes --version 0.1.0`. We would suggest doing this on a local machine and not a Puppet server as you need cfssl installed.

To install cfssl, see Cloudflare's [cfssl documentation](https://github.com/cloudflare/cfssl). Change directory into the root of the module and issue `bundle install`.
Then cd into the [tools](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/master/tooling) directory. You will now be able to run the `kube_tool`.

To look at the kube_tools help menu. Just issue `./kube_tool.rb` this will print out:

```puppet

Commands:
  kube_tool.rb build_hiera FQDN, IP, BOOTSTRAP_CONTROLLER_IP, ETCD_INITIAL_CLUSTER, ETCD_IP, KUBE_API_ADVERTISE_ADDRESS, INSTALL_DASHBOARD  # Pass the cluster params to build your hiera configuration
  kube_tool.rb help [COMMAND]                                                                                                               # Describe available commands or one specific command
```

So to generate the hiera file for my cluster I would use:

```puppet

./kube_tool.rb build_hiera kubernetes 172.17.10.101 172.17.10.101 "etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380"  "%{::ipaddress_enp0s8}"  "%{::ipaddress_enp0s8}" true
```

The parameters are:

* `FQDN`: the cluster fqdn.
* `BOOTSTRAP_CONTROLLER_IP`: the ip address of the controller puppet will use to create things like cluster role bindings, kube dns, and the Kubernetes dashboard.
* `ETCD_INITIAL_CLUSTER`: the server addresses. When in production, include three, five, or seven nodes for etcd. 
* `ETCD_IP` and `ETCD_IP KUBE_API_ADVERTISE_ADDRESS`: we recommend passing the fact for the interface to be used by the cluster. 
* `INSTALL_DASHBOARD`: a boolean to install the dashboard or not.

The tool creates a `kuberntes.yaml` file. To view the file contents on screen, run the `cat` command.

Add the `kuberntes.yaml` file to the Hiera directory on your Puppet server. 

The tool also creates a bootstrap token and base64 encodes any values that need to be encoded for Kubernetes. If you run the `cat` command again, all the values are re-generated, including the certificates and tokens. You can then use Jenkins or Bamboo to add the Hiera file to your control repository or version control application.

If you don't want to use the `kube_tools` configuration tool and want to manually configure the module, all of the parameters are listed in the [Reference](#reference) section and in the [init.pp](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/manifests/init.pp) file.


### Begininning with kubernetes

After your `kuberntes.yaml` file has been added to the Hiera directory on your Puppet server, configure your node with one of the following parameters:

* [bootstrap controller](###bootstrap-controller)
* [controller](###controller)
* [worker](###worker)

#### Bootstrap Controller

A bootstrap controller is the node a cluster uses to add cluster addons (such as kube dns, cluster role bindings etc). After the cluster is bootstrapped, the bootstrap controller becomes a normal controller.

To make a node a bootstrap controller, add the following code to the manifest:

```puppet

class {'kubernetes':
  controller           => true,
  bootstrap_controller => true,
  }
```

#### Controller

A controller in Kubernetes contains the control plane and `etcd`. In a production cluster you should have three, five, or seven controllers.

To make a node a controller, add the following code to the manifest:

```puppet

class {'kubernetes':
  controller => true,
  }
```

#### Worker

A worker node runs your applications. You can add as many of these as Kubernetes can handle. For information about nodes in Kubernetes, see the [Kubernetes docs](https://kubernetes.io/docs/concepts/architecture/nodes/#what-is-a-node).

To make a node a worker node, add the following code to the manifest:

```puppet

class {'kubernetes':
  woker => true,
  }
```

Please note that a node can not be a controller and a worker. It must be one or the other.

## Usage

This section is where you describe how to customize, configure, and do the fancy stuff with your module here. It's especially helpful if you include usage examples and code samples for doing things with your module.

## Reference

### Parameters

#### `kubernetes_version`

The version of the Kubernetes containers to install.

Defaults to  `1.7.3`.

#### `kubernetes_package_version`

The version the Kubernetes OS packages to install, such as kubectl and kubelet.

Defaults to `1.7.3`.

#### `cni_version`

The version of the cni package to install.

Defaults to `0.5.1`.

#### `kube_dns_version`

The version of kube DNS to install.

Defaults to `1.14.2`.

#### `controller`

Specifies whether to set the node as a Kubernetes controller.

Valid values are `true`, `false`.

Defaults to `false`.

#### `bootstrap_controller`

Specifies whether to set the node as the bootstrap controller.

The bootstrap controller is used only for creating the initial cluster.

Valid values are `true`, `false`.

Defaults to `false`.

#### `bootstrap_controller_ip`

The IP address of the bootstrap controller.

Defaults to `undef`.

#### `worker`

Specifies whether to set a node as a worker.

Defaults to `undef`.

#### `manage_epel`

Specifies whether you to manage epel for a RHEL box.

Valid values are `true`, `false`.

Defaults to `false`.

#### `kube_api_advertise_address`

The IP address you want exposed by the API server. 

An example with hiera would be `kubernetes::kube_api_advertise_address:"%{::ipaddress_enp0s8}"`.

Defaults to `undef`. 

#### `etcd_version`

The version of etcd to use.

Defaults to `3.0.17`.

#### `etcd_ip`

The IP address you want etcd to use for communications.

An example with hiera would be `kubernetes::etcd_ip:"%{::ipaddress_enp0s8}"`.

Defaults to `undef`.

#### `etcd_initial_cluster`

This will tell etcd how many nodes will be in the cluster and is passed as a string.

A Hiera example is `kubernetes::etcd_initial_cluster: etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380`.

Defaults to `undef`.

#### `bootstrap_token `

The token Kubernetes uses to start components.

For information on bootstrap tokens, see https://kubernetes.io/docs/admin/bootstrap-tokens/

Defaults to `undef`.

#### `bootstrap_token_name`

The name of the bootstrap token.

An example with hiera would be `kubernetes::bootstrap_token_name: bootstrap-token-95e1e0`.

Defaults to `undef`.

#### `bootstrap_token_description`

The base64 encoded description of the bootstrap token.

A Hiera example is `kubernetes::bootstrap_token_description: VGhlIGRlZmF1bHQgYm9vdHN0cmFwIHRva2VuIHBhc3NlZCB0byB0aGUgY2x1c3RlciB2aWEgUHVwcGV0Lg== # lint:ignore:140chars`. 

#### `bootstrap_token_id`

The base64 encoded ID the cluster uses to point to the token.

A Hiera example is `kubernetes::bootstrap_token_id: OTVlMWUwDQo=`.

Defaults to `undef`.

#### `bootstrap_token_secret`

The base64 encoded secret which validates the bootstrap token.

An example with hiera would be `kubernetes::bootstrap_token_secret: OTVlMWUwLmFlMmUzYjkwYTdmYjlkMzYNCg==`.

Defaults to `undef`.

#### `bootstrap_token_usage_bootstrap_authentication`

The base64 encoded bool which uses the bootstrap token. (true = dHJ1ZQ==)

An example with hiera would be `kubernetes::bootstrap_token_usage_bootstrap_authentication: dHJ1ZQ==`.

Defaults to `undef`.
   
#### `bootstrap_token_usage_bootstrap_signing`

The base64 encoded bool which uses the bootstrap signing. (true = dHJ1ZQ==)

An example with hiera would be `kubernetes::bootstrap_token_usage_bootstrap_signing: dHJ1ZQ==`.

Defaults to `undef`.

#### `certificate_authority_data`

The string value for the cluster ca certificate data.

Defaults to `undef`.

#### `client_certificate_data_controller`

The client certificate for the controller. Must be a string value. 

Defaults to `undef`.

#### `client_certificate_data_controller_manager`

The client certificate for the controller manager. Must be a string value. 

Defaults to `undef`.

#### `client_certificate_data_scheduler`

The client certificate for the scheduler. Must be a string value. 

Defaults to `undef`.

#### `client_certificate_data_worker`

The client certificate for the kubernetes worker. Must be a string value. 

Defaults to `undef`.

#### `client_key_data_controller`

The client certificate key for the controller. Must be a string value. 

Defaults to `undef`.

#### `client_key_data_controller_manager`

The client certificate key for the controller manager. Must be a string value. 

Defaults to `undef`.

#### `client_key_data_scheduler`

The client certificate key for the scheduler. Must be a string value. 

Defaults to `undef`.

#### `client_key_data_worker`

The client certificate key for the kubernetes worker. Must be a string value. 

Defaults to `undef`.

#### `apiserver_kubelet_client_crt`

The certificate for the kubelet api server. Must be a certificate value and not a file.

Defaults to `undef`.

#### `apiserver_kubelet_client_key`

The client key for the kubelet api server. Must be a certificate value and not a file. 

Defaults to `undef`.

#### `apiserver_crt`

The certificate for the api server. Must be a certificate value and not a file.

Defaults to `undef`.

#### `apiserver_key`

The key for the api server. Must be a certificate value and not a file.

Defaults to `undef`.

#### `ca_crt`

The ca certificate for the cluster. Must be a certificate value and not a file.

Defaults to `undef`.

#### `ca_key`

The ca key for the cluster. Must be a certificate value and not a file.

Defaults to `undef`.

#### `front_proxy_ca_crt`

The ca certificate for the front proxy. Must be a certificate value and not a file.

Defaults to `undef`.

#### `front_proxy_ca_key`

The ca key for the front proxy. Must be a certificate value and not a file.

Defaults to `undef`.

#### `front_proxy_client_crt`

The client certificate for the front proxy. Must be a certificate value and not a file.

Defaults to `undef`.

#### `front_proxy_client_key`

The client key for front proxy. Must be a certificate value and not a file.

Defaults to `undef`.

#### `sa_key`

The key for the service account. Must be a certificate value and not a file.  

Defaults to `undef`.

#### `sa_pub`

The public key for the service account. Must be a certificate value and not a file.

Defaults to `undef`.

#### `cni_network_provider`

The network deployment URL that kubectl can locate.

We support networking providers that supports cni.

This defaults to `https://git.io/weave-kube-1.6`.

#### `install_dashboard`

Specifies whether the kubernetes dashboard is installed.

Valid values are `true`, `false`.

Defaults to `false`.

## Limitations

This module supports [Kubernetes 1.6](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v160) and above.

This module supports only Puppet 4 and above.

## Development

If you would like to contribute to this module please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/CONTRIBUTING.md).
