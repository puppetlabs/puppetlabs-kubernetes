require 'yaml'
require 'securerandom'

class OtherParams



  def OtherParams.create(os, version, container_runtime, cni_provider, etcd_initial_cluster, etcd_ip, api_address, install_dashboard)
    if install_dashboard.match('true')
       install = true
    else
       install = false
    end

    if os.downcase.match('debian')
      kubernetes_package_version = "#{version}-00"
    elsif os.downcase.match('redhat')
      kubernetes_package_version = version
    end

    if cni_provider.match('weave')
       cni_network_provider = "https://cloud.weave.works/k8s/net?k8s-version=#{version}"
       cni_pod_cidr = '10.32.0.0/12'
    elsif
       cni_provider.match('flannel')
       cni_network_provider = 'https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml'
       cni_pod_cidr = '10.244.0.0/16'
    elsif cni_provider.match('calico')
       cni_network_provider = 'https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml'
       cni_pod_cidr = '192.168.0.0/16'
    end



    x = etcd_initial_cluster.split(",")
    cluster = String.new
    peers = String.new
    bootstrap_controller = x[0]
    z = bootstrap_controller.split(":")
    controller_address = "#{z[1]}:6443"
    x.each do | members |
      y  = members.split(":")
      hostname = y[0]
      ip = y[1]

      cluster = cluster + "#{hostname}=https://#{ip}:2380,"
      peers = peers + "#{ip},"
    end

    etcd_initial_cluster = cluster.chop
    etcd_peers = peers.chop
    etcd_peers = etcd_peers.split(",")
    api_server_count = x.length




    data = Hash.new
    data['kubernetes::kubernetes_version'] = version
    data['kubernetes::kubernetes_package_version'] = kubernetes_package_version
    data['kubernetes::container_runtime'] = container_runtime
    data['kubernetes::cni_network_provider'] = cni_network_provider
    data['kubernetes::cni_pod_cidr'] = cni_pod_cidr
    data['kubernetes::etcd_initial_cluster'] = etcd_initial_cluster
    data['kubernetes::etcd_peers'] = etcd_peers
    data['kubernetes::etcd_ip'] = etcd_ip
    data['kubernetes::kube_api_advertise_address'] = api_address
    data['kubernetes::api_server_count'] = api_server_count
    data['kubernetes::install_dashboard'] = install
    data['kubernetes::controller_address'] = controller_address
    data['kubernetes::token'] = SecureRandom.hex(3) + "." + SecureRandom.hex(8)
    File.open("kubernetes.yaml", "w+") { |file| file.write(data.to_yaml) }

  end
end
