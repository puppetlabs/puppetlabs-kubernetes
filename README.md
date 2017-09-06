# kubernetes

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with kubernetes](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kubernetes](#beginning-with-kubernetes)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs and configures Kubernetes https://kubernetes.io/
Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

It groups containers that make up an application into logical units for easy management and discovery.
Kubernetes builds upon 15 years of experience of running production workloads at Google, \
combined with best-of-breed ideas and practices from the community.

## Setup

### Setup Requirements

To make this module easy to pick up and get going we have included a tool that will auto generate
all the security params, bootstrap token, and other configs about your cluster into a hiera file.

To take advantage of this first install the module `puppet module install puppetlabs-kubernetes --version 0.1.0`
We would suggest doing this on a local machine and not a Puppet server as you need cfssl installed.
To install cfssl follow the instructions [here](https://github.com/cloudflare/cfssl)
Change directory into the root of the module and issue `bundle install`
Then cd into the [tools](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/master/tooling) directory
You will now be able to run the `kube_tool`

To look at the kube_tools help menu. just issue `./kube_tool.rb` this will print out

```puppet
Commands:
  kube_tool.rb build_heira FQDN, IP, BOOTSTRAP_CONTROLLER_IP, ETCD_INITIAL_CLUSTER, ETCD_IP, KUBE_API_ADVERTISE_ADDRESS, INSTALL_DASHBOARD  # Pass the cluster params to build your hiera configuration
  kube_tool.rb help [COMMAND]                                                                                                               # Describe available commands or one specific command
```

So to generate the hiera file for my cluster I would use

```puppet
./kube_tool.rb build_heira kubernetes 172.17.10.101 172.17.10.101 "etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380"  "%{::ipaddress_enp0s8}"  "%{::ipaddress_enp0s8}" true
```

The param for `FQDN` is the clusters fqdn, `BOOTSTRAP_CONTROLLER_IP` is the ip address of the controller puppet will use to create things like cluster role bindings, kube dns and the Kubernetes dashboard.
For the params of `ETCD_IP KUBE_API_ADVERTISE_ADDRESS` we recomend passing the fact for interface that you would like the cluster to use. For example I am using `%{::ipaddress_enp0s8}"`
You will also notice for the `ETCD_INITIAL_CLUSTER` I am passing 3 server addresses `"etcd-kube-master=http://172.17.10.101:2380,etcd-kube-replica-master-01=http://172.17.10.210:2380,etcd-kube-replica-master-02=http://172.17.10.220:2380"`
This is for high availiblity, if you wanted you could pass a single server address. When going this in a production environment please use either 3, 5 or 7 nodes for etcd.
`INSTALL_DASHBOARD` is a boolean to install the dashboard or not.

After the tool has run you will have a file called kuberntes.yaml. This is your hiera file to add to your Puppet server.

If you `cat` the file you will see it has created all the certificates that Kubernetes needs, you will also see that

### Beginning with kubernetes

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

Here, include a complete list of your module's classes, types, providers,
facts, along with the parameters for each. Users refer to this section (thus
the name "Reference") to find specific details; most users don't read it per
se.

## Limitations

This module will only support Kubernetes 1.6 and above due to the changes
that where introduced in that release. https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v160
The main feature that prevents us from supporting older releases of Kubernetes is rbac.

This module will only support Puppet 4 and above, due to use of functions like each

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel
are necessary or important to include here. Please use the `## ` header.
