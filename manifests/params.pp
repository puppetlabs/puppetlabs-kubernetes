# Kubernetes params

class kubernetes::params {

$kubernetes_version = '1.10.2'
case $::osfamily {
  'Debian' : {
    $kubernetes_package_version = "${kubernetes_version}-00"
    $docker_version = '17.03.0~ce-0~ubuntu-xenial'
  }
  'RedHat' : {
    $kubernetes_package_version = $kubernetes_version
    $docker_version = '17.03.1.ce-1.el7.centos'
  }
  default: { notify {"The OS family ${::osfamily} is not supported by this module":} }
}
$container_runtime = 'docker'
$containerd_version = '1.1.0'
$containerd_archive = "containerd-${containerd_version}.linux-amd64.tar.gz"
$containerd_source = "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${containerd_archive}"
$docker_package_name = 'docker-engine'
$etcd_version = '3.1.12'
$etcd_archive = "etcd-v${etcd_version}-linux-amd64.tar.gz"
$etcd_source = "https://github.com/coreos/etcd/releases/download/v${etcd_version}/${etcd_archive}"
$runc_version = '1.0.0-rc5'
$runc_source = "https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64"
$kubernetes_fqdn = 'kubernetes'
$controller = false
$bootstrap_controller = false
$worker =  false
$manage_docker = true
$manage_etcd = true
$kube_api_advertise_address = undef
$etcd_ip = undef
$etcd_initial_cluster = undef
$etcd_ca_key = undef
$etcd_ca_crt = undef
$etcdclient_key = undef
$etcdclient_crt = undef
$cni_network_provider = undef
$cni_pod_cidr = undef
$cni_rbac_binding = undef
$install_dashboard = false
$schedule_on_controller = false
$node_label = $::hostname
$api_server_count = undef
$etcd_peers = undef
$etcdserver_key = undef
$etcdpeer_crt = undef
$etcdserver_crt = undef
$etcdpeer_key = undef
$token = undef
$discovery_token_hash = undef
$kubernetes_ca_crt = undef
$kubernetes_ca_key = undef
$sa_key = undef
$sa_pub = undef
$apiserver_cert_extra_sans = []
$apiserver_extra_arguments = []
$service_cidr = '10.96.0.0/12'
$controller_address = undef
$cloud_provider = undef
$kubeadm_extra_config = {}
$kubernetes_apt_location = 'http://apt.kubernetes.io'
$kubernetes_apt_release = "kubernetes-${::lsbdistcodename}"
$kubernetes_apt_repos = 'main'
$kubernetes_config_template = 'kubernetes/config.yaml.erb'
$kubernetes_key_id = '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB'
$kubernetes_key_source = 'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
$kubernetes_yum_baseurl = 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64'
$kubernetes_yum_gpgkey = 'https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg'
$docker_apt_location = 'https://apt.dockerproject.org/repo'
$docker_apt_release = "ubuntu-${::lsbdistcodename}"
$docker_apt_repos = 'main'
$docker_yum_baseurl = 'https://yum.dockerproject.org/repo/main/centos/7'
$docker_yum_gpgkey = 'https://yum.dockerproject.org/gpg'
$docker_key_id = '58118E89F3A912897C070ADBF76221572C52609D'
$docker_key_source = 'https://apt.dockerproject.org/gpg'
$create_repos = true
$disable_swap = true
}

