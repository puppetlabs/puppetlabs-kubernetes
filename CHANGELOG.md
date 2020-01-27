# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v5.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.1.0) (2020-01-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.0.0...v5.1.0)

### Added

- Allow setting metricsBindAddress [\#377](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/377) ([TJM](https://github.com/TJM))
- Add docker\_extra\_daemon\_config for use when managing docker [\#376](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/376) ([mrwulf](https://github.com/mrwulf))
- Add support for managing Docker logging max-file and max-size settings. [\#358](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/358) ([nickperry](https://github.com/nickperry))
- Add possibility to run acceptance tests with Litmus and Vagrant [\#353](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/353) ([carabasdaniel](https://github.com/carabasdaniel))
- Add\_support\_1.16 [\#351](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/351) ([BaronMsk](https://github.com/BaronMsk))

### Fixed

- Fix worker k8s 1.6 [\#363](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/363) ([BaronMsk](https://github.com/BaronMsk))
- Configure extra\_volumes when cloud\_provider is set and cloud\_config is not. Fixes \#301 [\#361](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/361) ([nickperry](https://github.com/nickperry))
- Add support for readOnly and pathType fields on volumes [\#359](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/359) ([nickperry](https://github.com/nickperry))
- Adding all IPs for etcd servers to etcd server cert [\#350](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/350) ([blodone](https://github.com/blodone))
- repair/improve package installation [\#348](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/348) ([scoopex](https://github.com/scoopex))
- Use correct apt release on Debian/Ubuntu [\#338](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/338) ([aptituz](https://github.com/aptituz))
- Fix repository location for Ubuntu [\#337](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/337) ([aptituz](https://github.com/aptituz))
- Fixed v1beta1 JoinConfiguration template to match the documentation [\#332](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/332) ([Xartos](https://github.com/Xartos))

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.0.0) (2019-07-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v4.0.1...v5.0.0)

### Changed

- \(MODULES-9550\) - v5.0.0 Release Prep [\#324](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/324) ([sheenaajay](https://github.com/sheenaajay))
- \(FM-8100\) Update minimum supported Puppet version to 5.5.10 [\#291](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/291) ([sheenaajay](https://github.com/sheenaajay))

### Added

- Modify config\_version to kubernetes\_version mapping. Pre-req to supporting Kube 1.15 [\#308](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/308) ([nickperry](https://github.com/nickperry))
- add support for cilium network provider [\#265](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/265) ([SimonHoenscheid](https://github.com/SimonHoenscheid))

### Fixed

- Manage front-proxy ca certs - fixes \#275 [\#321](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/321) ([nickperry](https://github.com/nickperry))
- Expose ttl duration parameter [\#313](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/313) ([carabasdaniel](https://github.com/carabasdaniel))
- make proxy mode configurable [\#297](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/297) ([mrwulf](https://github.com/mrwulf))
- Fixed duplicate tlsBootstrapToken in config\_worker.yaml.erb for kubernetes 1.14 [\#287](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/287) ([Hillkorn](https://github.com/Hillkorn))

## [v4.0.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v4.0.1) (2019-05-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/4.0.0...v4.0.1)

### Fixed

- cluster name missing tag brackets in worker config [\#280](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/280) ([jorhett](https://github.com/jorhett))
- Avoid log message about waiting for SA when it already exists [\#278](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/278) ([jorhett](https://github.com/jorhett))
- MODULES-8947 fixing bugs and tests [\#274](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/274) ([sheenaajay](https://github.com/sheenaajay))

# Version 4.0.0

Upgrade tasks for version v1beta1

Upgrade kubeadmn templates for v1beta1 (kubernetes versions 1.13.+)

Ability to change etcd hostname

Ability to change Kubernetes dashboard url

A full list of PR's and issues closed can be found here [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/7)

# Version 3.4.0

Add Puppet Bolt tasks to interact with the Kubernetes API

# Version 3.3.0

Moves env variable to init.pp

Set cgroup driver in config file

Ability to change cluster name

Restrucuture config class

New defined type for SA in new namespaces

A full list of PR's and issues closed can be found here [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/7?closed=1)

# Version 3.2.2

Fixes bug where nodes in v1.10/11 could not join the cluster

A full list of PR's and issues closed can be found here [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/6)

# Version 3.2.1

Fixes world readable PKI keys in /etc/kubernetes/config.yaml

Allows changing etcd cluster state with new param

A full list of PR's and issues closed can be found here [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/5)

# Version 3.2.0

Includes support for 1.13.x with the alpha3 config files

Uses config file for join tasks

Versions Dashboard

Enables kubelet service on RHEL/Centos

Removes params.pp in favor of data in init.pp

A full list of PR's and issues closed can be found here [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/4)

# Version 3.1.0

Adds support for Kubernetes 1.12.x

A full list of PR's and issues closed can be found here [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/3?closed=1)

https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/3?closed=1
# Version 3.0.1

Fixes an incorrect default value for ignore_preflight_errors in the cluster_roles class

# Version 3.0.0

Exposes a significant number of new params to allow the use of internal repos in restricted or airgapped systems.

A full list of PRs and issues closed can be found [here](https://github.com/puppetlabs/puppetlabs-kubernetes/milestone/2?closed=1)

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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
