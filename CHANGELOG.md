<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v8.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v8.1.0) - 2024-12-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v8.0.0...v8.1.0)

### Added

- pdksync - (MAINT) - Allow Stdlib 9.x [#635](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/635) ([LukasAud](https://github.com/LukasAud))

### Fixed

- (CAT-2180) Upgrade rexml to address CVE-2024-49761 [#691](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/691) ([amitkarsale](https://github.com/amitkarsale))
- Fix calico-tigera installation problems [#639](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/639) ([jorhett](https://github.com/jorhett))
- Fix flannel install condition [#615](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/615) ([deric](https://github.com/deric))

### Other

- Add newline at end of file [#678](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/678) ([waipeng](https://github.com/waipeng))
- Fix container_runtime default in comment [#677](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/677) ([waipeng](https://github.com/waipeng))
- Ensure correct scheduler extra arguments passed to v1beta3 template [#670](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/670) ([treydock](https://github.com/treydock))
- Update devcontainer format + Ruby vscode extension [#666](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/666) ([jorhett](https://github.com/jorhett))

## [v8.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v8.0.0) - 2023-06-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v7.1.1...v8.0.0)

### Changed

- (CONT-786) Add Support for Puppet 8 / Drop Support for Puppet 6 [#633](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/633) ([david22swan](https://github.com/david22swan))
- Make cgroup_driver default to systemd [#631](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/631) ([r-tierney](https://github.com/r-tierney))

### Added

- (CONT-585) allow deferred function for auth password [#637](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/637) ([Ramesh7](https://github.com/Ramesh7))

## [v7.1.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v7.1.1) - 2023-05-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v7.1.0...v7.1.1)

### Fixed

- General fixes [#625](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/625) ([r-tierney](https://github.com/r-tierney))
- (CONT-358) Syntax update [#616](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/616) ([LukasAud](https://github.com/LukasAud))

## [v7.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v7.1.0) - 2023-01-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v7.0.0...v7.1.0)

### Added

- Reproducible kube-tool build [#605](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/605) ([deric](https://github.com/deric))
- add new parameter node_extra_taints [#586](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/586) ([BaronMsk](https://github.com/BaronMsk))

## [v7.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v7.0.0) - 2022-12-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v6.3.0...v7.0.0)

### Changed

- Validate namespace parameter as DNS subdomain name [#602](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/602) ([deric](https://github.com/deric))
- (MAINT) Fixing codebase hardening issues [#590](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/590) ([LukasAud](https://github.com/LukasAud))

### Added

- Support overriding containerd socket path (#596) [#597](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/597) ([deric](https://github.com/deric))
- Rewrite command line arguments parsing [#593](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/593) ([deric](https://github.com/deric))
- add new parameter containerd_sandbox_image [#587](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/587) ([BaronMsk](https://github.com/BaronMsk))
- Add RedHat family as supported OS (#563) [#577](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/577) ([deric](https://github.com/deric))
- Support Debian 11 [#568](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/568) ([deric](https://github.com/deric))
- Support changing bits used for generating certificates [#566](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/566) ([deric](https://github.com/deric))
- Add proxy support to docker, cri_containerd and kubelet [#561](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/561) ([nickperry](https://github.com/nickperry))
- Remove cgroup-driver arg to avoid deprecation warnings [#540](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/540) ([treydock](https://github.com/treydock))

### Fixed

- Stronger type checking for $node_name [#600](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/600) ([deric](https://github.com/deric))
- (MAINT) Revert hardening changes [#599](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/599) ([chelnak](https://github.com/chelnak))
- Fix executing CNI addons commands (fixes #594) [#598](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/598) ([deric](https://github.com/deric))
- Addressing wrong type for unless execs [#592](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/592) ([LukasAud](https://github.com/LukasAud))
- Fix Build docker image tooling [#589](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/589) ([BaronMsk](https://github.com/BaronMsk))
- (CONT-217) Correct Kubernetes etcd_data_dir spec tests [#582](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/582) ([GSPatton](https://github.com/GSPatton))
- etcd data dir path configurable by hiera [#581](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/581) ([GSPatton](https://github.com/GSPatton))
- Hardening manifest classes [#575](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/575) ([LukasAud](https://github.com/LukasAud))
- Master role has been deprecated since kubernetes v1.20.0 [#571](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/571) ([deric](https://github.com/deric))
- Don't try to guess docker_version (#564) [#565](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/565) ([deric](https://github.com/deric))
- fix: anchor regex for determining config_version [#554](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/554) ([TheMeier](https://github.com/TheMeier))
- pdksync - (GH-iac-334) Remove Support for Ubuntu 16.04 [#548](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/548) ([david22swan](https://github.com/david22swan))
- Fix #541 [#542](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/542) ([nickperry](https://github.com/nickperry))
- Update Debian-family docker repo location and key id [#535](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/535) ([jorhett](https://github.com/jorhett))

## [v6.3.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v6.3.0) - 2021-09-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v6.2.0...v6.3.0)

### Added

- Support Kubernetes 1.22 and kubeadm v1beta3 configurations [#531](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/531) ([treydock](https://github.com/treydock))
- Enable live-restore for Docker daemon. [#530](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/530) ([peteroruba](https://github.com/peteroruba))

## [v6.2.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v6.2.0) - 2021-07-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v6.1.0...v6.2.0)

### Added

- Allow configuring of waiting times during sa creation [#519](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/519) ([ZloeSabo](https://github.com/ZloeSabo))

### Fixed

- Support for kubernetes dashboard version 2.0.0 and onwards [#528](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/528) ([danifr](https://github.com/danifr))
- Support both standard Calico and Calico Tigera [#511](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/511) ([treydock](https://github.com/treydock))

## [v6.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v6.1.0) - 2021-05-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v6.0.0...v6.1.0)

### Added

- Add config.toml for containerd installed with 'archive' [#516](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/516) ([danifr](https://github.com/danifr))
- Improvements to containerd configs when using a package [#510](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/510) ([treydock](https://github.com/treydock))
- Add kubeadm skip-phases option [#507](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/507) ([BaronMsk](https://github.com/BaronMsk))
- Configure image registry settings for  containerd when installed via package [#500](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/500) ([andreas-stuerz](https://github.com/andreas-stuerz))

### Fixed

- (IAC-1497) - Removal of unsupported `translate` dependency [#501](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/501) ([david22swan](https://github.com/david22swan))
- Repair containerd archive [#497](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/497) ([daianamezdrea](https://github.com/daianamezdrea))
- Added information about Hiera YAML Lookup; installing a updated version. [#494](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/494) ([bitvijays](https://github.com/bitvijays))

## [v6.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v6.0.0) - 2021-03-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.5.0...v6.0.0)

### Changed

- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#480](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/480) ([carabasdaniel](https://github.com/carabasdaniel))

### Added

- Add etcd_listen_metric_urls parameter [#470](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/470) ([treydock](https://github.com/treydock))
- add etc max-request-bytes option [#464](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/464) ([AblionGE](https://github.com/AblionGE))

### Fixed

- Fix template [#484](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/484) ([daianamezdrea](https://github.com/daianamezdrea))
- Bump containerd version to 1.5.0 and fix source link [#483](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/483) ([daianamezdrea](https://github.com/daianamezdrea))
- Update criSocket to avoid deprecation warnings [#475](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/475) ([treydock](https://github.com/treydock))
- Fix calico CNI support [#473](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/473) ([djschaap](https://github.com/djschaap))
- Ensure that changes to etcd systemd reload and restart etcd [#471](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/471) ([treydock](https://github.com/treydock))
- Allow tmp_directory to be changed [#462](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/462) ([treydock](https://github.com/treydock))

## [v5.5.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.5.0) - 2020-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.4.0...v5.5.0)

### Added

- Support installing containerd using a package [#460](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/460) ([treydock](https://github.com/treydock))
- pdksync - (feat) - Add support for puppet 7 [#459](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/459) ([daianamezdrea](https://github.com/daianamezdrea))

## [v5.4.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.4.0) - 2020-11-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.3.0...v5.4.0)

### Added

- Add scheduler_extra_arguments parameter [#451](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/451) ([treydock](https://github.com/treydock))
- Add configuration options for conntrack settings in v1beta1 and v1beta2 [#447](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/447) ([Wiston999](https://github.com/Wiston999))
- Implement advertise address for etcd [#443](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/443) ([faxm0dem](https://github.com/faxm0dem))

### Fixed

- Remove invalid kube-proxy config resourceContainer [#448](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/448) ([treydock](https://github.com/treydock))
- Updates docker yumrepo default [#436](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/436) ([JasonWhall](https://github.com/JasonWhall))

## [v5.3.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.3.0) - 2020-09-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.2.0...v5.3.0)

### Added

- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch `main` [#428](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/428) ([david22swan](https://github.com/david22swan))
- Package pinning and auto restart of etcd [#420](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/420) ([scoopex](https://github.com/scoopex))
- Delegated PKI and adapt to k8s 1.15.3+ [#412](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/412) ([Wiston999](https://github.com/Wiston999))
- Add option to set the dns domain in kubernetes cluster [#405](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/405) ([BaronMsk](https://github.com/BaronMsk))

### Fixed

- Update default yum repositories for docker [#414](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/414) ([carabasdaniel](https://github.com/carabasdaniel))
- Remove invalid field "max" from conntrack spec [#407](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/407) ([nickperry](https://github.com/nickperry))

## [v5.2.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.2.0) - 2020-05-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.1.0...v5.2.0)

### Added

- (FEAT) Add docker storage options [#383](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/383) ([AblionGE](https://github.com/AblionGE))

### Fixed

- Create client certificates per server with SAN values [#382](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/382) ([AblionGE](https://github.com/AblionGE))

## [v5.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.1.0) - 2020-01-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v5.0.0...v5.1.0)

### Added

- Allow setting metricsBindAddress [#377](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/377) ([TJM](https://github.com/TJM))
- Add docker_extra_daemon_config for use when managing docker [#376](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/376) ([mrwulf](https://github.com/mrwulf))
- Add support for managing Docker logging max-file and max-size settings. [#358](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/358) ([nickperry](https://github.com/nickperry))
- Add possibility to run acceptance tests with Litmus and Vagrant [#353](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/353) ([carabasdaniel](https://github.com/carabasdaniel))
- Add_support_1.16 [#351](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/351) ([BaronMsk](https://github.com/BaronMsk))

### Fixed

- Fix worker k8s 1.6 [#363](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/363) ([BaronMsk](https://github.com/BaronMsk))
- Configure extra_volumes when cloud_provider is set and cloud_config is not. Fixes #301 [#361](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/361) ([nickperry](https://github.com/nickperry))
- Add support for readOnly and pathType fields on volumes [#359](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/359) ([nickperry](https://github.com/nickperry))
- Adding all IPs for etcd servers to etcd server cert [#350](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/350) ([blodone](https://github.com/blodone))
- repair/improve package installation [#348](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/348) ([scoopex](https://github.com/scoopex))
- Use correct apt release on Debian/Ubuntu [#338](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/338) ([aptituz](https://github.com/aptituz))
- Fix repository location for Ubuntu [#337](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/337) ([aptituz](https://github.com/aptituz))
- Fixed v1beta1 JoinConfiguration template to match the documentation [#332](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/332) ([Xartos](https://github.com/Xartos))

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v5.0.0) - 2019-07-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/v4.0.1...v5.0.0)

### Changed

- (MODULES-9550) - v5.0.0 Release Prep [#324](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/324) ([sheenaajay](https://github.com/sheenaajay))
- (FM-8100) Update minimum supported Puppet version to 5.5.10 [#291](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/291) ([sheenaajay](https://github.com/sheenaajay))

### Added

- Modify config_version to kubernetes_version mapping. Pre-req to supporting Kube 1.15 [#308](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/308) ([nickperry](https://github.com/nickperry))
- add support for cilium network provider [#265](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/265) ([SimonHoenscheid](https://github.com/SimonHoenscheid))

### Fixed

- Manage front-proxy ca certs - fixes #275 [#321](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/321) ([nickperry](https://github.com/nickperry))
- (IAC-181) Expose ttl duration parameter [#313](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/313) ([carabasdaniel](https://github.com/carabasdaniel))
- make proxy mode configurable [#297](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/297) ([mrwulf](https://github.com/mrwulf))
- Fixed duplicate tlsBootstrapToken in config_worker.yaml.erb for kubernetes 1.14 [#287](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/287) ([Hillkorn](https://github.com/Hillkorn))

## [v4.0.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/v4.0.1) - 2019-05-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/4.0.0...v4.0.1)

### Fixed

- Add extra arguments for API server and controller manager [#282](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/282) ([fydai](https://github.com/fydai))
- cluster name missing tag brackets in worker config [#280](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/280) ([jorhett](https://github.com/jorhett))
- Avoid log message about waiting for SA when it already exists [#278](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/278) ([jorhett](https://github.com/jorhett))
- MODULES-8947 fixing bugs and tests [#274](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/274) ([sheenaajay](https://github.com/sheenaajay))

## [4.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/4.0.0) - 2019-04-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.4.0...4.0.0)

### Added

- Add kubeadm v1beta1 [#272](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/272) ([carabasdaniel](https://github.com/carabasdaniel))

### Other

- Tasks 1.14 - add new tasks for version v1beta1, update changelog and metadata [#273](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/273) ([lionce](https://github.com/lionce))
- Etcd hostname variable [#271](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/271) ([sw0x2A](https://github.com/sw0x2A))
- add in logo for certified k8s installer [#268](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/268) ([davejrt](https://github.com/davejrt))
- introduce kubernetes_dashboard_url param [#266](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/266) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- removes redundant variables in the case of not using the cloud provider [#264](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/264) ([davejrt](https://github.com/davejrt))

## [3.4.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.4.0) - 2019-03-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.3.0...3.4.0)

### Other

- Add in Puppet Bolt tasks [#263](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/263) ([carabasdaniel](https://github.com/carabasdaniel))

## [3.3.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.3.0) - 2019-03-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.2.2...3.3.0)

### Other

- release 3.3.0 [#262](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/262) ([davejrt](https://github.com/davejrt))
- Make kubectl environment available in main class [#261](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/261) ([jorhett](https://github.com/jorhett))
- Store cgroup driver in kubeadm configuration file for kubernetes 1.12+ [#259](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/259) ([jorhett](https://github.com/jorhett))
- Add support to change kubernetes cluster name [#255](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/255) ([jorhett](https://github.com/jorhett))
- Restructure kubenetes::config to kubenetes::config::kubeadm [#254](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/254) ([jorhett](https://github.com/jorhett))
- Safe command lines for CNI network installs [#253](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/253) ([jorhett](https://github.com/jorhett))
- Workaround race condition on default sa creation [#247](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/247) ([jorhett](https://github.com/jorhett))

## [3.2.2](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.2.2) - 2019-02-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.2.1...3.2.2)

### Other

- releasing 3.2.2 [#252](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/252) ([davejrt](https://github.com/davejrt))
- fixes old nodes using config file [#250](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/250) ([davejrt](https://github.com/davejrt))
- Allow etcd to be installed through system packages [#165](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/165) ([ralphje](https://github.com/ralphje))

## [3.2.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.2.1) - 2019-02-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.2.0...3.2.1)

### Other

- Update CHANGELOG.md [#249](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/249) ([davejrt](https://github.com/davejrt))
- restricts access to kube dirs to root only [#248](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/248) ([davejrt](https://github.com/davejrt))
- Allow setting etcd initial cluster state [#246](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/246) ([clly](https://github.com/clly))
- Remove dependency on puppet-wget (use puppet-archive instead) [#243](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/243) ([JayH5](https://github.com/JayH5))

## [3.2.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.2.0) - 2019-01-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.1.0...3.2.0)

### Other

- updating changelog and metadata for 3.2.0 release [#240](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/240) ([davejrt](https://github.com/davejrt))
- Mount cloud configuration on ApiServer and ControllerManager pods [#236](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/236) ([jorhett](https://github.com/jorhett))
- Fix alpha3 template [#235](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/235) ([jorhett](https://github.com/jorhett))
- Use fact method to more gracefully handle missing facts [#234](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/234) ([ralimi](https://github.com/ralimi))
- Honor overridden service address range in alpha3 config. [#233](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/233) ([ralimi](https://github.com/ralimi))
- Fix systemd cpu/memory problems on RedHat [#230](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/230) ([jorhett](https://github.com/jorhett))
- updating calico URL [#229](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/229) ([davejrt](https://github.com/davejrt))
- Dashboard no longer has deploy YAML on master branch [#228](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/228) ([jorhett](https://github.com/jorhett))
- Fix cni network provider [#227](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/227) ([kkuehlz](https://github.com/kkuehlz))
- Reduce redundant test fill by using Hiera for default values [#226](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/226) ([jorhett](https://github.com/jorhett))
- Fix CentOS repos [#225](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/225) ([jorhett](https://github.com/jorhett))
- Build config file for worker nodes too [#224](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/224) ([jorhett](https://github.com/jorhett))
- Fix cloud_provider hostnames [#223](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/223) ([jorhett](https://github.com/jorhett))
- Defer os-specific default value test to avoid fact availability issues [#222](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/222) ([jorhett](https://github.com/jorhett))
- Update go version [#220](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/220) ([davejrt](https://github.com/davejrt))
- Fix multiple errors in cloud configuration [#219](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/219) ([jorhett](https://github.com/jorhett))
- enable kubelet service [#215](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/215) ([davejrt](https://github.com/davejrt))
- updates for puppet 6 [#214](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/214) ([davejrt](https://github.com/davejrt))
- adding in logic for managing kmod alternatively [#213](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/213) ([davejrt](https://github.com/davejrt))
- Remove legacy facts [#212](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/212) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- Move kubernetesVersion into ClusterConfiguration [#210](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/210) ([nickperry](https://github.com/nickperry))
- adding in ordering for sysctl to present failures [#206](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/206) ([davejrt](https://github.com/davejrt))
- document manage_kernel_modules and manage_sysctl_settings, remove doc… [#205](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/205) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- removes redundant variable and fixes error with to_yaml [#201](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/201) ([davejrt](https://github.com/davejrt))
- fixing alignment in init.pp and problem with variables in config3  [#200](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/200) ([davejrt](https://github.com/davejrt))
- fix fixtures.yaml, set right author/source for wget module [#199](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/199) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- Add support for configuring kubeletExtraArgs in v1alpha3 config. [#198](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/198) ([nickperry](https://github.com/nickperry))
- Move parameter definition back to head of init.pp (fixes #169) [#193](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/193) ([temujin9](https://github.com/temujin9))
- Remove Execs for Kmod management and setting Sysctl values with accor… [#192](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/192) ([SimonHoenscheid](https://github.com/SimonHoenscheid))

## [3.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.1.0) - 2018-11-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.0.1...3.1.0)

### Other

- upadting metadata and changelog for new release [#191](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/191) ([davejrt](https://github.com/davejrt))
- (CLOUD 2195) Readme update. [#189](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/189) ([EamonnTP](https://github.com/EamonnTP))
- Support customized kubelet configuration. [#187](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/187) ([ralimi](https://github.com/ralimi))
- adds in option to specify alternate image repo [#186](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/186) ([davejrt](https://github.com/davejrt))
- adds in k8s version variable [#185](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/185) ([davejrt](https://github.com/davejrt))
- Updated stdlib version requirement to >= 4.20 [#182](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/182) ([yoshz](https://github.com/yoshz))
- adds in support for 1.12.x  [#181](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/181) ([davejrt](https://github.com/davejrt))
- (Maint)Pinning puppet version until puppet 6 support added. [#176](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/176) ([MWilsonPuppet](https://github.com/MWilsonPuppet))
- (maint) Fix function nil / undef conditionals for Puppet6 [#173](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/173) ([suckatrash](https://github.com/suckatrash))
- updating rakefile for ci [#167](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/167) ([davejrt](https://github.com/davejrt))
- fixes instructions to use env file, with correct filename [#163](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/163) ([davejrt](https://github.com/davejrt))
- removing unused etcd template [#162](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/162) ([davejrt](https://github.com/davejrt))
- 3.0.1 [#159](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/159) ([davejrt](https://github.com/davejrt))
- Add feature flag for managing Etcd [#157](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/157) ([jonasdemoor](https://github.com/jonasdemoor))

## [3.0.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.0.1) - 2018-08-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/3.0.0...3.0.1)

### Other

- fixing type in param value [#156](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/156) ([davejrt](https://github.com/davejrt))
- Typo [#155](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/155) ([turbodog](https://github.com/turbodog))
- bumping metadata.json for new release [#154](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/154) ([davejrt](https://github.com/davejrt))

## [3.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/3.0.0) - 2018-08-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/2.0.2...3.0.0)

### Other

- Fix module hard requirement for apt to < 6.0.0 [#153](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/153) ([meltingrobot](https://github.com/meltingrobot))
- (maint) Updated .sync.yml [#150](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/150) ([bmjen](https://github.com/bmjen))
- (CLOUD-2054) Readme updates. [#149](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/149) ([EamonnTP](https://github.com/EamonnTP))
- (CLOUD-1978) pdk changes for k8 module [#148](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/148) ([sheenaajay](https://github.com/sheenaajay))
- Flatten fix [#146](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/146) ([davejrt](https://github.com/davejrt))
-  Add feature flag for managing Docker repositories and packages [#144](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/144) ([jonasdemoor](https://github.com/jonasdemoor))
- Cleaning up apiServerExtraArgs [#143](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/143) ([mrwulf](https://github.com/mrwulf))
- Fixed indenting issue when configuring multiple extra apiserver cert SANs [#142](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/142) ([yoshz](https://github.com/yoshz))
- Allow arbitrary extra kubeadm config.yaml snippets [#141](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/141) ([Zetten](https://github.com/Zetten))
- adding in tests for cloud provider in service class [#140](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/140) ([davejrt](https://github.com/davejrt))
- updating readme with new params [#139](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/139) ([davejrt](https://github.com/davejrt))
- adds in param to configure rbac for calico [#137](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/137) ([davejrt](https://github.com/davejrt))
- disables swap [#136](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/136) ([davejrt](https://github.com/davejrt))
- adding in puppet wget module [#135](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/135) ([davejrt](https://github.com/davejrt))
- paramaters for different upstream repos and OS flavors [#134](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/134) ([davejrt](https://github.com/davejrt))
- adds in the option to disable repo install, or override repos and URLs for offline installs [#133](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/133) ([davejrt](https://github.com/davejrt))
- fix wrong folder name [#132](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/132) ([khaefeli](https://github.com/khaefeli))
- Fixed missing cloud provider arguments for kubelet [#131](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/131) ([yoshz](https://github.com/yoshz))
- Clean up README [#129](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/129) ([alex-harvey-z3q](https://github.com/alex-harvey-z3q))
- kubernetes::cluster_roles - ignore CNI errors on `kubeadm join` [#127](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/127) ([tskirvin](https://github.com/tskirvin))
- Update metadata.json [#125](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/125) ([davejrt](https://github.com/davejrt))
- Fix for failing idempotency on worker nodes [#120](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/120) ([AranVinkItility](https://github.com/AranVinkItility))
- Revert "Fix error: parameter 'api_server_count' expects an Integer value, got…" [#115](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/115) ([davejrt](https://github.com/davejrt))
- Fix error: parameter 'api_server_count' expects an Integer value, got… [#113](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/113) ([Lord-Y](https://github.com/Lord-Y))
- release updates [#110](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/110) ([davejrt](https://github.com/davejrt))

## [2.0.2](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/2.0.2) - 2018-06-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/2.0.1...2.0.2)

### Other

- fixes issue with cgroup mismatch on rhel and ignore flags for containerd runtime [#109](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/109) ([davejrt](https://github.com/davejrt))
- prepping for release [#108](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/108) ([davejrt](https://github.com/davejrt))

## [2.0.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/2.0.1) - 2018-06-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/2.0.0...2.0.1)

### Other

- updating default runtime [#107](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/107) ([davejrt](https://github.com/davejrt))
- 2.0.0 [#106](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/106) ([davejrt](https://github.com/davejrt))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/2.0.0) - 2018-06-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/1.1.0...2.0.0)

### Other

- README.md - use current version number [#101](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/101) ([tskirvin](https://github.com/tskirvin))
- calico is actually supported [#99](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/99) ([KlavsKlavsen](https://github.com/KlavsKlavsen))
- bumping version in metadata.json and updating changelog [#94](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/94) ([davejrt](https://github.com/davejrt))
- Allow mounting extra volumes to apiserver pod [#89](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/89) ([Zetten](https://github.com/Zetten))
- Pin versions of debian packages [#86](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/86) ([admont](https://github.com/admont))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/1.1.0) - 2018-04-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/1.0.3...1.1.0)

### Added

- Expose a lot of params - mostly to ease deployments in a different overlay network range [#82](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/82) ([mrwulf](https://github.com/mrwulf))

### Other

- Update spec_helper_acceptance.rb [#93](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/93) ([davejrt](https://github.com/davejrt))
- Kube tool [#91](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/91) ([davejrt](https://github.com/davejrt))
- Update gpg key fingerprint used by K8s Ubuntu repo [#90](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/90) ([admont](https://github.com/admont))
- fix for cfssl trust no longer being in the vendor path [#88](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/88) ([scotty-c](https://github.com/scotty-c))
- Update kube_addons.pp [#87](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/87) ([scotty-c](https://github.com/scotty-c))
- Fix log message typos: Kubernets -> Kubernetes [#84](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/84) ([wkalt](https://github.com/wkalt))
- fix for RHEL repo [#81](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/81) ([scotty-c](https://github.com/scotty-c))
- Issue template [#77](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/77) ([davejrt](https://github.com/davejrt))
- Cloud 1731 [#76](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/76) ([davejrt](https://github.com/davejrt))
- Update CONTRIBUTING.md [#74](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/74) ([davejrt](https://github.com/davejrt))
- changing taint and label to fqdn [#73](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/73) ([davejrt](https://github.com/davejrt))
- (maint) Fix some typos in the readme [#72](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/72) ([lucywyman](https://github.com/lucywyman))
- Cloud 1739 [#69](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/69) ([davejrt](https://github.com/davejrt))
- Cloud 1712 [#68](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/68) ([davejrt](https://github.com/davejrt))
- Update default values [#67](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/67) ([scotty-c](https://github.com/scotty-c))
- updates for release 1.0.3 [#64](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/64) ([davejrt](https://github.com/davejrt))

## [1.0.3](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/1.0.3) - 2018-02-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/1.0.2...1.0.3)

### Other

- fixes weave URL in kube_tool and uses default IP range [#63](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/63) ([davejrt](https://github.com/davejrt))
- (fixing lint warning for k8) [#61](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/61) ([sheenaajay](https://github.com/sheenaajay))
- Bugfix/docker apt repo gpg key fix [#58](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/58) ([admont](https://github.com/admont))
- (CLOUD-1701) Add path attribute to execs in kube_addons [#57](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/57) ([abottchen](https://github.com/abottchen))
- release 1.0.2 [#56](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/56) ([scotty-c](https://github.com/scotty-c))

## [1.0.2](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/1.0.2) - 2018-01-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/1.0.1...1.0.2)

### Other

- Fix to stop RHEL family downgrading cni [#55](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/55) ([scotty-c](https://github.com/scotty-c))
- Revert "(CLOUD-1640) Remove package resource for kubernetes-cni" [#54](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/54) ([scotty-c](https://github.com/scotty-c))
- (CLOUD-1640) Remove package resource for kubernetes-cni [#53](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/53) ([abottchen](https://github.com/abottchen))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/1.0.1) - 2018-01-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/1.0.0...1.0.1)

### Other

- 1.0.1 [#51](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/51) ([scotty-c](https://github.com/scotty-c))
- Flannel support [#50](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/50) ([scotty-c](https://github.com/scotty-c))
- (maint)undoing change made when testing [#48](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/48) ([MWilsonPuppet](https://github.com/MWilsonPuppet))
- Allow additional configuration of API Server [#47](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/47) ([Zetten](https://github.com/Zetten))
- (automated build) [#45](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/45) ([MWilsonPuppet](https://github.com/MWilsonPuppet))
- Cloud 1595 [#44](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/44) ([davejrt](https://github.com/davejrt))
- removing epel from the module [#43](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/43) ([scotty-c](https://github.com/scotty-c))
- (i18n Gem update for k8) [#42](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/42) ([sheenaajay](https://github.com/sheenaajay))
- (CLOUD-1664) Remove validate functions adddatatype [#41](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/41) ([sheenaajay](https://github.com/sheenaajay))
- supported release of module [#39](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/39) ([davejrt](https://github.com/davejrt))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/1.0.0) - 2018-01-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/0.2.0...1.0.0)

### Other

- Update README to use new puppet/kubetool image [#38](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/38) ([ccaum](https://github.com/ccaum))
- 0.2.0 [#32](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/32) ([davejrt](https://github.com/davejrt))

## [0.2.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/0.2.0) - 2017-12-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/0.1.4...0.2.0)

### Added

- Cri containerd dave [#31](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/31) ([davejrt](https://github.com/davejrt))

### Other

- (CLOUD-1614) Fix acceptance tests to run on centos [#30](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/30) ([sheenaajay](https://github.com/sheenaajay))
- (CLOUD-1593) fix acceptance test on vagrant k8 [#28](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/28) ([sheenaajay](https://github.com/sheenaajay))
- k8_jenkins [#27](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/27) ([sheenaajay](https://github.com/sheenaajay))
- fixing acceptance tests [#25](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/25) ([davejrt](https://github.com/davejrt))

## [0.1.4](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/0.1.4) - 2017-11-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/0.1.3...0.1.4)

### Other

- (dashboard deploy for each version) [#26](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/26) ([sheenaajay](https://github.com/sheenaajay))
- fixing acceptance tests [#25](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/25) ([davejrt](https://github.com/davejrt))
- updating for release [#24](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/24) ([davejrt](https://github.com/davejrt))

## [0.1.3](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/0.1.3) - 2017-11-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/0.1.2...0.1.3)

### Other

- Readme edits [#23](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/23) ([EamonnTP](https://github.com/EamonnTP))
- Kubetool [#22](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/22) ([davejrt](https://github.com/davejrt))
- Kube 1.8.3 support [#21](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/21) ([scotty-c](https://github.com/scotty-c))

## [0.1.2](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/0.1.2) - 2017-11-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/0.1.1...0.1.2)

### Other

- fixing hardcoded hostname [#20](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/20) ([davejrt](https://github.com/davejrt))

## [0.1.1](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/0.1.1) - 2017-11-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/0.1.0...0.1.1)

### Other

- (release) release prep for 0.1.1 [#19](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/19) ([gregohardy](https://github.com/gregohardy))
- (metadata dependencies options) [#18](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/18) ([sheenaajay](https://github.com/sheenaajay))
- Remove hard-coded address from proxy configmap template [#17](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/17) ([brektyme](https://github.com/brektyme))
- Fix typo on kubernetes.yaml [#15](https://github.com/puppetlabs/puppetlabs-kubernetes/pull/15) ([rhoml](https://github.com/rhoml))

## [0.1.0](https://github.com/puppetlabs/puppetlabs-kubernetes/tree/0.1.0) - 2017-10-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-kubernetes/compare/6919126dfbc4a76d520ad35d4a914dfa38bec4f3...0.1.0)
