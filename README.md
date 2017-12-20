[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-kubernetes.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-kubernetes)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppetlabs/kubernetes.svg)](https://forge.puppetlabs.com/puppetlabs/kubernetes)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppetlabs/kubernetes.svg)](https://forge.puppetlabs.com/puppetlabs/kubernetes)

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

The included configuration tool `kube_tools` auto generates all the security parameters, the bootstrap token, and other configurations for your cluster into a file. The `kube_tool` requires Ruby 2.3 and above.

1. cfssl is a requirement, so we recommend you install the module on a local machine and not a Puppet server by running this command:

```puppet
puppet module install puppetlabs-kubernetes --version 0.2.0
```

2. Install cfssl. See Cloudflare's [cfssl documentation](https://github.com/cloudflare/cfssl).

3. Change directory into the root of the module, and run the `bundle install` command.

4. Change directory into the [tools](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/master/tooling) directory, and run the `kube_tool` command.

5. To view the help menu, run the `./kube_tool.rb -h` command.

The kube_tools help menu:

```puppet
Usage: kube_tool [options]
    -o, --os-type os-type            the os that kubernetes will run on
    -v, --version version            the kubernetes version to install
    -r container runtime,            the container runtime to use. this can only be docker or cri_containerd
        --container_runtime
    -f, --fqdn fqdn                  fqdn
    -i, --ip ip                      ip
    -b bootstrap,                    the bootstrap controller ip address
        --bootstrap-controller-ip
    -e etcd_initial_cluster,         members of the initial etcd cluster
        --etcd-initial-cluster
    -t, --etcd-ip etcd_ip            ip address of etcd
    -a, --api-address api_address    the ip address that kube api will listen on
    -d dashboard,                    install the kube dashboard
        --install-dashboard
    -h, --help                       Displays Help
```

So to generate the hiera file for my cluster I use:

```puppet
./kube_tool.rb -o debian -v 1.8.4 -r docker -f kubernetes -i 172.17.10.101 -b 172.17.10.101 -e "etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380" -t "%{::ipaddress_enp0s8}" -a "%{::ipaddress_enp0s8}" -d true
```

The parameters are:

* `OS`: the os kubernetes will run on.
* `VERSION`: the version of kubernetes you want to deploy
* `CONTAINER_RUNTIME`: the container runtime kubernetes will use, this can only be set to `docker` or `cri_containerd`
* `FQDN`: the cluster fqdn.
* `BOOTSTRAP_CONTROLLER_IP`: the ip address of the controller puppet will use to create things like cluster role bindings, kube dns, and the Kubernetes dashboard.
* `ETCD_INITIAL_CLUSTER`: the server addresses. When in production, include three, five, or seven nodes for etcd.
* `ETCD_IP` and `ETCD_IP KUBE_API_ADVERTISE_ADDRESS`: we recommend passing the fact for the interface to be used by the cluster.
* `INSTALL_DASHBOARD`: a boolean to install the dashboard or not.

The tool creates a `kubernetes.yaml` file. To view the file contents on screen, run the `cat` command.

6. Add the `kubernetes.yaml` file to the Hiera directory on your Puppet server.

The tool also creates a bootstrap token and base64 encodes any values that need to be encoded for Kubernetes. If you run the `cat` command again, all the values are re-generated, including the certificates and tokens. You can then use Jenkins or Bamboo to add the Hiera file to your control repository or version control application.

If you don't want to use the `kube_tools` configuration tool and want to manually configure the module, all of the parameters are listed in the [Reference](#reference) section and in the [init.pp](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/manifests/init.pp) file.

If you don't want to install the dependencies in your local environment, a Dockerfile is included. To build, change directory into the tooling directory, and run the `docker build -t puppet/kubetool` command.

The docker image takes each of the parameters as environment variables. When run as follows it will output a kubernetes.yaml file in your current working directory:

```puppet
docker run -v $(pwd):/mnt -e FQDN=kubernetes -e IP=172.17.10.101 -e BOOTSTRAP_CONTROLLER_IP=172.17.10.101 -e ETCD_INITIAL_CLUSTER="etcd-kube-master=http://172.17.10.101:2380" -e ETCD_IP="%{::ipaddress_enp0s8}" -e KUBE_API_ADVERTISE_ADDRESS="%{::ipaddress_enp0s8}" -e INSTALL_DASHBOARD=true puppetlabs/kubetool
```


### Begininning with kubernetes

After your `kubernetes.yaml` file has been added to the Hiera directory on your Puppet server, configure your node with one of the following parameters:

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
  worker => true,
}
```

Please note that a node can not be a controller and a worker. It must be one or the other.

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

#### `container_runtime`

Choose between docker or cri_containerd

Defaults to docker

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

If set to 'none' no cni plugin is installed.

This defaults to `https://git.io/weave-kube-1.6`.

#### `install_dashboard`

Specifies whether the kubernetes dashboard is installed.

Valid values are `true`, `false`.

Defaults to `false`.

## Limitations

This module supports [Kubernetes 1.6](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v160) and above.

This module supports only Puppet 4 and above.

This module has been tested on the following OS

RedHat 7.x
CentOS 7.x
Ubuntu 16.04

## Development

If you would like to contribute to this module please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/CONTRIBUTING.md).
