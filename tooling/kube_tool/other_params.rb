# frozen_string_literal: true

require 'yaml'
require 'securerandom'

# OTher Parameters
class OtherParams
  def self.create(opts)
    version = opts[:version]
    container_runtime = opts[:container_runtime]
    kubernetes_minor_release = version.match(%r{(\d+\.)(\d+)})[0]

    kubernetes_package_version = case opts[:os].downcase
                                 when 'debian'
                                   "#{version}-00"
                                 when 'redhat'
                                   version
                                 else
                                   version
                                 end

    case opts[:cni_provider]
    when 'weave'
      cni_network_provider = 'https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml'
      cni_pod_cidr = '10.32.0.0/12'
    when 'flannel'
      cni_network_provider = 'https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml'
      cni_pod_cidr = '10.244.0.0/16'
    when 'calico'
      cni_network_provider = "https://docs.projectcalico.org/archive/v#{opts[:cni_provider_version]}/manifests/calico.yaml"
      cni_pod_cidr = '192.168.0.0/16'
    when 'calico-tigera'
      cni_network_preinstall = "https://raw.githubusercontent.com/projectcalico/calico/v#{opts[:cni_provider_version]}/manifests/tigera-operator.yaml"
      cni_network_provider = "https://raw.githubusercontent.com/projectcalico/calico/v#{opts[:cni_provider_version]}/manifests/custom-resources.yaml"
      cni_pod_cidr = '192.168.0.0/16'
    when 'cilium'
      cni_pod_cidr = '10.244.0.0/16'
      if container_runtime.match?('docker')
        cni_network_provider = "https://raw.githubusercontent.com/cilium/cilium/#{opts[:cni_provider_version]}/examples/kubernetes/#{kubernetes_minor_release}/cilium.yaml"
      elsif container_runtime.match?('crio')
        cni_network_provider = "https://raw.githubusercontent.com/cilium/cilium/#{opts[:cni_provider_version]}/examples/kubernetes/#{kubernetes_minor_release}/cilium-crio.yaml"
      end
    end

    x = opts[:etcd_initial_cluster].split(',')
    cluster = +''
    peers = +''
    bootstrap_controller = x[0]
    z = bootstrap_controller.split(':')
    controller_address = "#{z[1]}:6443"
    x.each do |members|
      y = members.split(':')
      hostname = y[0]
      ip = y[1]

      cluster += "#{hostname}=https://#{ip}:2380,"
      peers += "#{ip},"
    end

    etcd_initial_cluster = cluster.chop
    etcd_peers = peers.chop
    etcd_peers = etcd_peers.split(',')
    api_server_count = x.length

    data = {}
    data['kubernetes::kubernetes_version'] = version
    data['kubernetes::kubernetes_package_version'] = kubernetes_package_version
    data['kubernetes::container_runtime'] = container_runtime
    data['kubernetes::cni_network_preinstall'] = cni_network_preinstall if cni_network_preinstall
    data['kubernetes::cni_network_provider'] = cni_network_provider
    data['kubernetes::cni_pod_cidr'] = cni_pod_cidr
    data['kubernetes::cni_provider'] = opts[:cni_provider]
    data['kubernetes::etcd_initial_cluster'] = etcd_initial_cluster
    data['kubernetes::etcd_peers'] = etcd_peers
    data['kubernetes::etcd_ip'] = opts[:etcd_ip]
    data['kubernetes::kube_api_advertise_address'] = opts[:api_address]
    data['kubernetes::api_server_count'] = api_server_count
    data['kubernetes::install_dashboard'] = opts[:install_dashboard]
    data['kubernetes::controller_address'] = controller_address
    data['kubernetes::token'] = "#{SecureRandom.hex(3)}.#{SecureRandom.hex(8)}"
    File.write('kubernetes.yaml', data.to_yaml)
  end
end
