#!/usr/bin/env ruby

require 'thor'
require_relative 'kube_tool/pre_checks.rb'
require_relative 'kube_tool/create_certs.rb'
require_relative 'kube_tool/create_token.rb'
require_relative 'kube_tool/clean_up.rb'
require_relative 'kube_tool/other_params.rb'

class Kube_tool < Thor
  desc "build_hiera FQDN, IP, BOOTSTRAP_CONTROLLER_IP, ETCD_INITIAL_CLUSTER, ETCD_IP, KUBE_API_ADVERTISE_ADDRESS, INSTALL_DASHBOARD", "Pass the cluster params to build your hiera configuration"
  def build_hiera(fqdn, ip, bootstrap_controller_ip, etcd_initial_cluster, etcd_ip, kube_api_advertise_address, install_dashboard)
    PreChecks.checks
    CreateCerts.ca
    CreateCerts.api_servers(fqdn, ip)
    PreChecks.checks
    CreateCerts.sa
    CreateCerts.admin
    CreateCerts.apiserver_kubelet_client
    CreateCerts.front_proxy_ca
    CreateCerts.front_proxy_client
    CreateCerts.system_node
    CreateCerts.kube_controller_manager
    CreateCerts.kube_scheduler
    CreateCerts.kube_workers
    CreateToken.bootstrap
    OtherParams.create(bootstrap_controller_ip, fqdn, etcd_initial_cluster, etcd_ip, kube_api_advertise_address, install_dashboard)    
    CleanUp.remove_files
  end 
end
Kube_tool.start(ARGV)
