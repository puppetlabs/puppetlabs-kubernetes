require 'yaml'

class OtherParams

  def OtherParams.create(os, version, container_runtime, cni_provider, bootstrap_controller_ip, fqdn, etcd_initial_cluster, etcd_ip, kube_api_advertise_address, install_dashboard, kube_api_service_ip)
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

    cni_cluster_cidr = nil
    cni_node_cidr = nil
    cni_node_cidr = true
    cluster_service_cidr = '10.96.0.0/12'
    kube_dns_ip = '10.96.0.10'

    if cni_provider.match('weave')
       cni_network_provider = 'https://git.io/weave-kube-1.6'
       cni_cluster_cidr = '10.32.0.0/12'
    elsif
       cni_provider.match('flannel')
       cni_network_provider = 'https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml'
       cni_cluster_cidr = '10.244.0.0/16'
    elsif cni_provider.match('calico')
	    cni_network_provider = 'https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml'
       cni_cluster_cidr = '192.168.0.0/16'
    end

    data = Hash.new
    data['kubernetes::kubernetes_version'] = version
    data['kubernetes::kubernetes_package_version'] = kubernetes_package_version
    data['kubernetes::container_runtime'] = container_runtime
    data['kubernetes::cni_network_provider'] = cni_network_provider
    data['kubernetes::cni_cluster_cidr'] = cni_cluster_cidr
    data['kubernetes::cni_node_cidr'] = cni_node_cidr
    data['kubernetes::cluster_service_cidr'] = cluster_service_cidr
    data['kubernetes::kubernetes_fqdn'] = fqdn
    data['kubernetes::bootstrap_controller_ip'] = bootstrap_controller_ip
    data['kubernetes::etcd_initial_cluster'] = etcd_initial_cluster
    data['kubernetes::etcd_ip'] = etcd_ip
    data['kubernetes::kube_api_advertise_address'] = kube_api_advertise_address
    data['kubernetes::install_dashboard'] = install
    data['kubernetes::kube_api_service_ip'] = kube_api_service_ip
    data['kubernetes::kube_dns_ip'] = kube_dns_ip
    File.open("kubernetes.yaml", "w+") { |file| file.write(data.to_yaml) }

  end
end
