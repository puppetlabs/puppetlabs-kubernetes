require 'yaml'

class OtherParams

  def OtherParams.create(bootstrap_controller_ip, fqdn, etcd_initial_cluster, etcd_ip, kube_api_advertise_address, install_dashboard)
    if install_dashboard.match('true')
       install = true 
    else
       install = false
    end   
    data = Hash.new
    data['kubernetes::kubernetes_fqdn'] = fqdn
    data['kubernetes::bootstrap_controller_ip'] = bootstrap_controller_ip
    data['kubernetes::etcd_initial_cluster'] = etcd_initial_cluster
    data['kubernetes::etcd_ip'] = etcd_ip
    data['kubernetes::kube_api_advertise_address'] = kube_api_advertise_address
    data['kubernetes::install_dashboard'] = install
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
    File.write("kubernetes.yaml",File.open("kubernetes.yaml",&:read).gsub(/^---$/," "))
  end
end  
