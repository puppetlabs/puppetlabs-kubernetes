[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-kubernetes.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-kubernetes)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppetlabs/kubernetes.svg)](https://forge.puppetlabs.com/puppetlabs/kubernetes)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppetlabs/kubernetes.svg)](https://forge.puppetlabs.com/puppetlabs/kubernetes)

# Kubernetes

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with kubernetes](#setup)
   * [Generating the module configuration](#generating-the-module-configuration)
   * [Adding the OS and hostname yaml files to Hiera](#adding-the-`{$OS}.yaml`-and-`{$hostname}.yaml`-files-to-Hiera)
   * [Configuring your node](#configuring-your-node)
   * [Validating and unit testing the module](#validating-and-unit-testing-the-module)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
   * [Classes](#classes)
   * [Defined types](#definedtypes)
   * [Parameters](#parameters)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
6. [Examples - Puppet Bolt task examples](#examples)

## Description

[<img
src="https://github.com/cncf/artwork/blob/04763c0f5f72b23d6a20bfc9c68c88cee805dbcc/projects/kubernetes/certified-kubernetes/1.13/color/certified-kubernetes-1.13-color.png"
align="right" width="150px" alt="certified kubernetes 1.13">][certified]

[certified]: https://github.com/cncf/k8s-conformance/tree/master/v1.13/puppetlabs-kubernetes

This module installs and configures [Kubernetes](https://kubernetes.io/) which is an open-source system for automating deployment, scaling, and management of containerized applications. For efficient management and discovery, containers that make up an application are grouped into logical units.

To bootstrap a Kubernetes cluster in a secure and extensible way, this module uses the [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) toolkit.




## Setup

[Install](https://puppet.com/docs/puppet/5.5/modules_installing.html) this module, [generate the configuration](#generating-the-module-configuration), [add the OS and hostname yaml files to Hiera](#adding-the-`{$OS}.yaml`-and-`{$hostname}.yaml`-files-to-Hiera), and [configure your node](#configuring-your-node).

Included in this module is [Kubetool](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/tooling/kube_tool.rb), a configuration tool that auto-generates the Hiera security parameters, the discovery token hash, and other configurations for your Kubernetes cluster. To simplify installation and use, the tool is available as a Docker image.

### Generating the module configuration

If Docker is not installed on your workstation, install it from [here](https://docs.docker.com/install/).

The Kubetool Docker image takes each parameter as an environment variable.

**Note:**: The version of Kubetool you use must match the version of the module on the Puppet Forge. For example, if using the module version 1.0.0, use `puppet/kubetool:1.0.0`.

To output a yaml file into your working directory that corresponds to the operating system you want Kubernetes to run on, and for each controller node, run either of these `docker run` commands:

```
docker run --rm -v $(pwd):/mnt --env-file env puppet/kubetool:{$module_version}
```

The `docker run` command above includes an `env` file which is included in the root folder of this repo.

```
docker run --rm -v $(pwd):/mnt -e OS=ubuntu -e VERSION=1.10.2 -e CONTAINER_RUNTIME=docker -e CNI_PROVIDER=cilium -e CNI_PROVIDER_VERSION=1.4.3 -e ETCD_INITIAL_CLUSTER=kube-master:172.17.10.101,kube-replica-master-01:172.17.10.210,kube-replica-master-02:172.17.10.220 -e ETCD_IP="%{networking.ip}" -e KUBE_API_ADVERTISE_ADDRESS="%{networking.ip}" -e INSTALL_DASHBOARD=true puppet/kubetool:{$module-version}
```

The above parameters are:

* `OS`: The operating system Kubernetes runs on.
* `VERSION`: The version of Kubernetes to deploy.
* `CONTAINER_RUNTIME`: The container runtime Kubernetes uses. Set this value to `docker` (officially supported) or `cri_containerd`. Advanced Kubernetes users can use `cri_containerd`, however this requires an increased understanding of Kubernetes, specifically when running applications in a HA cluster. To run a HA cluster and access your applications, an external load balancer is required in front of your cluster. Setting this up is beyond the scope of this module. For more information, see the Kubernetes [documentation](https://kubernetes-v1-4.github.io/docs/user-guide/load-balancer/).
* `CNI_PROVIDER`: The CNI network to install. Set this value to `weave`, `flannel`, `calico` or `cilium`.
* `CNI_PROVIDER_VERSION` The CNI version to use `calico` and `cilium` use this variable to reference the correct deployment file. Current version for `calico` is `3.6` and `cilium` is `1.4.3`
* `ETCD_INITIAL_CLUSTER`: The server hostnames and IPs in the form of `hostname:ip`. When in production, include three, five, or seven nodes for etcd.
* `ETCD_IP`: The IP each etcd member listens on. We recommend passing the fact for the interface to be used by the cluster.
* `KUBE_API_ADVERTISE_ADDRESS`: The IP each etcd/apiserver instance uses on each controller. We recommend passing the fact for the interface to be used by the cluster.
* `INSTALL_DASHBOARD`: A boolean which specifies whether to install the dashboard.

Kubetool creates:

* A yaml file that corresponds to the operating system specified by the `OS` parameter. To view the file contents, run `cat Debian.yaml` for a Debian system, or run `cat RedHat.yaml` for RedHat. The yaml files produced for each member of the etcd cluster contain certificate information to bootstrap an initial etcd cluster. Ensure these are also placed in your hieradata directory at the node level.

* A discovery token hash and encoded values required by Kubernetes. To regenerate the values, including certificates and tokens, run the `kubetool` command again.

### Adding the `{$OS}.yaml` and `{$hostname}.yaml` files to Hiera

Add the `{$OS}.yaml` file to the same [control repo](https://puppet.com/docs/pe/2018.1/control_repo.html) where your [Hiera](https://puppet.com/docs/hiera) data is, usually the `data` directory. By leveraging location facts, such as the [pp_datacenter](https://puppet.com/docs/puppet/5.5/ssl_attributes_extensions.html#reference-5482) [trusted fact](https://puppet.com/docs/puppet/5.5/lang_facts_and_builtin_vars.html#trusted-facts), each cluster can be allocated its own configuration.

### Configuring your node

After the `{$OS}.yaml` and `{$hostname}.yaml` files have been added to the Hiera directory on your Puppet server, configure your node as the controller or worker.

A controller node contains the control plane and etcd. In a production cluster, you should have three, five, or seven controllers. A worker node runs your applications. You can add as many worker nodes as Kubernetes can handle. For information about nodes in Kubernetes, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/architecture/nodes/#what-is-a-node).

**Note:**: A node cannot be a controller and a worker. It must be one or the other.

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

### Validating and unit testing the module

This module is compliant with the Puppet Development Kit [(PDK)](https://puppet.com/docs/pdk/1.x/pdk.html), which provides tools to help run unit tests on the module and validate the modules's metadata, syntax, and style.

*Note:* To run static validations and
unit tests against this module using the [`pdk validate`](https://puppet.com/docs/pdk/1.x/pdk_reference.html#pdk-validate-command) and [`pdk test unit`](https://puppet.com/docs/pdk/1.x/pdk_reference.html#pdk-test-unit-command) commands, you must have Puppet 5 or higher installed. In the following examples we have specified Puppet 5.3.6.

To validate the metadata.json file, run the following command:

```
pdk validate metadata --puppet-version='5.3.6'
```

To validate the Puppet code and syntax, run the following command:

```
pdk validate puppet --puppet-version='5.3.6'
```

**Note:** The `pdk validate ruby` command ignores the excluded directories specified in the .rubocop.yml file. Therefore, to validate the Ruby code style and syntax you must specify the directory the code exists in.

In the following example we validate the Ruby code contained in the lib directory:

```
pdk validate ruby lib --puppet-version='5.3.6'
```

To unit test the module, run the following command:

```
pdk test unit --puppet-version='5.3.6'
```

## Reference

### Classes

#### Public classes

* kubernetes

#### Private classes

* kubernetes::cluster_roles
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

#### `apiserver_cert_extra_sans`

A string array of Subject Alternative Names for the API server certificates.

Defaults to `[]`.

#### `apiserver_extra_arguments`

A string array of extra arguments passed to the API server.

Defaults to `[]`.

#### `apiserver_extra_volumes`

A hash of extra volumes mounts mounted on the API server.

For example,

```puppet
apiserver_extra_volumes => {
  'volume-name' => {
    hostPath  => '/data',
    mountPath => '/data',
    readOnly: => 'false',
    pathType: => 'DirectoryOrCreate'
  },
}
```

Defaults to `{}`.

#### `cloud_provider`

The name of the cloud provider configured in `/etc/kubernetes/cloud-config`.

**Note**: This file is not managed within this module and must be present before bootstrapping the Kubernetes controller.

Defaults to `undef`.

#### `cloud_config`

The location of the cloud config file used by `cloud_provider`. For use with v1.12 and above.

**Note**: This file is not managed within this module and must be present before bootstrapping the Kubernetes controller.

Defaults to `undef`.

#### `cni_network_provider`

The URL to get the CNI providers yaml file. `kube_tool` sets this value.

Defaults to `undef`.

#### `cni_rbac_binding`

The download URL for the cni providers rbac rules. Only for use with Calico.

Defaults to `undef`.

#### `cni_pod_cidr`

Specifies the overlay (internal) network range to use. This value is set by `kube_tool` per `CNI_PROVIDER`.

Defaults to `undef`.

#### `container_runtime`

Specifies the runtime that the Kubernetes cluster uses.

Valid values are `cri_containerd` or `docker`.

Defaults to `docker`.

#### `controller`

Specifies whether to set the node as a Kubernetes controller.

Valid values are `true`, `false`.

Defaults to `false`.

#### `containerd_version`

Specifies the version of the containerd runtime the module installs.

Defaults to `1.1.0`.

#### `containerd_archive`

The name of the containerd archive.

Defaults to `containerd-${containerd_version}.linux-amd64.tar.gz`.

#### `containerd_source`

The download URL for the containerd archive.

Defaults to `https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}`.

#### `controller_address`

The IP address and port for the controller the worker node joins. For example `172.17.10.101:6443`.

Defaults to `undef`.

#### `controllermanager_extra_arguments`

A string array of extra arguments passed to the controller manager.

Defaults to `[]`.

#### `controllermanager_extra_volumes`

A hash of extra volumes mounts mounted on the controller manager container.

For example,

```puppet
controllermanager_extra_volumes => {
  'volume-name' => {
    hostPath  => '/data',
    mountPath => '/data',
    readOnly: => 'false',
    pathType: => 'DirectoryOrCreate'
  },
}
```

Defaults to `{}`.


#### `create_repos`

Specifies whether to install the upstream Kubernetes and Docker repos.

Valid values are `true`, `false`.

Defaults to `true`.

#### `disable_swap`

Specifies whether to turn off swap setting. This is required for kubeadm.

Valid values are `true`, `false`.

Defaults to `true`.

#### `manage_kernel_modules`
 
Specifies whether to manage the kernel modules needed for kubernetes

Valid values are `true`, `false`.

Defaults to `true`

#### `manage_sysctl_settings`

Specifies whether to manage the the sysctl settings needed for kubernetes

Valid values are `true`, `false`.

Defaults to `true`

#### `discovery_token_hash`

The string used to validate to the root CA public key when joining a cluster. This value is created by `kubetool`.

Defaults to `undef`.

#### `docker_apt_location`

The APT repo URL for the Docker packages.

Defaults to `https://apt.dockerproject.org/repo`.

#### `docker_apt_release`

The release name for the APT repo for the Docker packages.

Defaults to `'ubuntu-${::lsbdistcodename}'`.

#### `docker_apt_repos`

The repos to install from the Docker APT url.

Defaults to `main`.

#### `docker_version`

Specifies the version of the Docker runtime to install.

Defaults to:
- `17.03.0.ce-1.el7.centos` on RedHat.
- `17.03.0~ce-0~ubuntu-xenial` on Ubuntu.

#### `docker_package_name`

The docker package name to download from an upstream repo.

Defaults to `docker-engine`.

#### `docker_key_id`

The gpg key for the Docker APT repo.

Defaults to `'58118E89F3A912897C070ADBF76221572C52609D'`.

#### `docker_key_source`

The URL for the Docker APT repo gpg key.

Defaults to `https://apt.dockerproject.org/gpg`.

#### `docker_yum_baseurl`

The YUM repo URL for the Docker packages.

Defaults to `https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64`.

#### `docker_yum_gpgkey`

The URL for the Docker yum repo gpg key.

Defaults to `https://yum.dockerproject.org/gpg`.

#### `docker_storage_driver`

The storage driver for Docker (added to '/etc/docker/daemon.json')

Defaults to `overlay2`.

#### `docker_storage_opts`

The storage options for Docker (Array added to '/etc/docker/daemon.json')

Defaults to `undef`.

#### `docker_extra_daemon_config`

Extra daemons options

Defaults to `undef`.

#### `etcd_version`

Specifies the version of etcd.

Defaults to `3.1.12`.

#### `etcd_archive`

Specifies the name of the etcd archive.

Defaults to `etcd-v${etcd_version}-linux-amd64.tar.gz`.

#### `etcd_source`

The download URL for the etcd archive.

Defaults to `https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}`.

#### `etcd_install_method`
The method on how to install etcd. Can be either `wget` (using etcd_source) or `package` (using $etcd_package_name)

Defaults to `wget`.

#### `etcd_package_name`

The system package name for installing etcd

Defaults to `etcd-server`.

#### `etcd_hostname`

Specifies the name of the etcd instance.

A Hiera is `kubernetes::etcd_hostname:"%{::fqdn}"`.

Defaults to `$hostname`.

#### `etcd_ip`

Specifies the IP address etcd uses for communications.

A Hiera is `kubernetes::etcd_ip:"%{networking.ip}"`.

Defaults to `undef`.

#### `etcd_initial_cluster`

Informs etcd on how many nodes are in the cluster.

A Hiera example is `kubernetes::etcd_initial_cluster: kube-master:172.17.10.101,kube-replica-master-01:172.17.10.210,kube-replica-master-02:172.17.10.220`.

Defaults to `undef`.

#### `etcd_initial_cluster_state`

Informs etcd on the state of the cluster when starting. Useful for adding single nodes to a cluster. Allowed values are `new` or `existing`.

Defaults to `new`

#### `etcd_peers`

Specifies how etcd lists the peers to connect to the cluster.

A Hiera example is `kubernetes::etcd_peers`:
* 172.17.10.101
* 172.17.10.102
* 172.17.10.103

Defaults to `undef`

#### `etcd_ca_key`

The CA certificate key data for the etcd cluster. This value must be passed as string and not as a file.

Defaults to `undef`.

#### `etcd_ca_crt`

The CA certificate data for the etcd cluster. This value must be passed as string and not as a file.

Defaults to `undef`.

#### `etcdclient_key`

The client certificate key data for the etcd cluster. This value must be passed as string and not as a file.

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

#### image_repository

The container registry to pull control plane images from.

Defaults to k8s.gcr.io

#### `install_dashboard`

Specifies whether the Kubernetes dashboard is installed.

Valid values are `true`, `false`.

Defaults to `false`.

#### `kubernetes_ca_crt`

The cluster's CA certificate. Must be passed as a string and not a file.

Defaults to `undef`.

#### `kubernetes_ca_key`

The cluster's CA key. Must be passed as a string and not a file.

Defaults to `undef`.

#### `kubernetes_front_proxy_ca_crt`

The cluster's front-proxy CA certificate. Must be passed as a string and not a file.

Defaults to `undef`.

#### `kubernetes_front_proxy_ca_key`

The cluster's front-proxy CA key. Must be passed as a string and not a file.

Defaults to `undef`.

#### `kube_api_advertise_address`

The IP address you want exposed by the API server.

A Hiera example is `kubernetes::kube_api_advertise_address:"%{networking.ip}"`.

Defaults to `undef`.

#### `kubernetes_version`

The version of the Kubernetes containers to install.

Defaults to  `1.10.2`.

#### `kubernetes_package_version`

The version the Kubernetes OS packages to install, such as `kubectl` and `kubelet`.

Defaults to `1.10.2`.

#### `kubeadm_extra_config`

A hash containing extra configuration data to be serialised with `to_yaml` and appended to the config.yaml file used by kubeadm.

Defaults to `{}`.

#### `kubelet_extra_config`

A hash containing extra configuration data to be serialised with `to_yaml` and appended to Kubelet configuration file for the cluster. Requires DynamicKubeletConfig.

Defaults to `{}`.

#### `kubelet_extra_arguments`

A string array to be appended to kubeletExtraArgs in the Kubelet's nodeRegistration configuration. It is applied to both masters and nodes. Use this for critical Kubelet settings such as `pod-infra-container-image` which may be problematic to configure via kubelet_extra_config and DynamicKubeletConfig.

Defaults to `[]`.

#### `kubernetes_apt_location`

The APT repo URL for the Kubernetes packages.

Defaults to `https://apt.kubernetes.io`.

#### `kubernetes_apt_release`

The release name for the APT repo for the Kubernetes packages.

Defaults to `'kubernetes-${::lsbdistcodename}'`.

#### `kubernetes_apt_repos`

The repos to install using the Kubernetes APT URL.

Defaults to `main`.

#### `kubernetes_key_id`

The gpg key for the Kubernetes APT repo.

Defaults to `'54A647F9048D5688D7DA2ABE6A030B21BA07F4FB'`.

#### `kubernetes_key_source`

The URL for the APT repo gpg key.

Defaults to `https://packages.cloud.google.com/apt/doc/apt-key.gpg`.

#### `kubernetes_yum_baseurl`

The YUM repo URL for the Kubernetes packages.

Defaults to `https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64`.

#### `kubernetes_yum_gpgkey`

The URL for the Kubernetes yum repo gpg key.

Defaults to `https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg`.

#### `manage_docker`

Specifies whether to install Docker repositories and packages via this module.

Valid values are `true`, `false`.

Defaults to `true`.

#### `manage_etcd`

Specifies whether to install an external Etcd via this module.

Valid values are `true`, `false`.

Defaults to `true`.

#### `node_label`

An override to the label of a node.

Defaults to `hostname`.

#### `runc_source`

The download URL for `runc`.

Defaults to `https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64`.

#### `runc_version`

Specifies the version of `runc` to install.

Defaults to `1.0.0-rc5`.

#### `sa_key`

The key for the service account. This value must be a certificate value and not a file.

Defaults to `undef`.

#### `sa_pub`

The public key for the service account. This value must be a certificate value and not a file.

Defaults to `undef`.

#### `schedule_on_controller`

Specifies whether to remove the master role and allow pod scheduling on controllers.

Valid values are `true`, `false`.

Defaults to `false`.

#### `service_cidr`

The IP address range for service VIPs.

Defaults to `10.96.0.0/12`.

#### `token`

The string used to join nodes to the cluster. This value must be in the form of `[a-z0-9]{6}.[a-z0-9]{16}`.

Defaults to `undef`.

#### `worker`

Specifies whether to set the node as a Kubernetes worker.

Valid values are `true`, `false`.

Defaults to `false`.

## Limitations

This module supports:

* Puppet 4 or higher.
* Kubernetes [1.10.x](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md#v160) or higher.
* Ruby 2.3.0 or higher.

This module has been tested on the following operating systems:

* RedHat 7.x.
* CentOS 7.x.
* Ubuntu 16.04

Docker is the supported container runtime for this module.

## Development

If you would like to contribute to this module, please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/CONTRIBUTING.md). For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)

To run the acceptance tests you can use Puppet Litmus with the Vagrant provider by using the following commands:

    bundle exec rake 'litmus:provision_list[all_supported]'
    bundle exec rake 'litmus:install_agent[puppet5]'
    bundle exec rake 'litmus:install_module'
    bundle exec rake 'litmus:acceptance:parallel'

As currently Litmus does not allow memory size and cpu size parameters for the Vagrant provisioner task we recommend to manually update the Vagrantfile used by the provisioner and add at least the following specifications for the puppetlabs-kubernetes module acceptance tests:

**Update Vagrantfile in the file: spec/fixtures/modules/provision/tasks/vagrant.rb**
    vf = <<-VF 
    Vagrant.configure(\"2\") do |config|
    config.vm.box = '#{platform}'
    config.vm.boot_timeout = 600
    config.ssh.insert_key = false
    config.vm.hostname = "testkube"
    config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = "2"
    end
    #{network}
    #{synced_folder}
    end
    VF

## Examples

In the examples folder you will find a [bash script](https://github.com/puppetlabs/puppetlabs-kubernetes/blob/master/examples/task_examples.sh) containg a few sample Puppet Bolt commands for the usage of the tasks. The example script is intended to be used with a Kubernetes API that requires the token authentication header, but the token parameter is optional by default.  
