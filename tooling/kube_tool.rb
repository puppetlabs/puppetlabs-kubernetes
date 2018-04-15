#!/usr/bin/env ruby

require 'optparse'
require_relative 'kube_tool/pre_checks.rb'
require_relative 'kube_tool/create_certs.rb'
require_relative 'kube_tool/create_token.rb'
require_relative 'kube_tool/clean_up.rb'
require_relative 'kube_tool/other_params.rb'

options = {:os                         => nil,
           :version                    => nil,
           :container_runtime          => nil,
           :cni_provider               => nil,
           :fqdn                       => nil,
           :ip                         => nil,
           :bootstrap_controller_ip    => nil,
           :etcd_initial_cluster       => nil,
           :etcd_ip                    => nil,
           :kube_api_advertise_address => nil,
      	   :install_dashboard          => nil,
           :kube_api_service_ip        => '10.96.0.1'
          }

parser = OptionParser.new do|opts|

  opts.on('-o', '--os-type os-type', 'the os that kubernetes will run on') do |os|
    options[:os] = os;
  end

  opts.on('-v', '--version version', 'the kubernetes version to install') do |version|
    options[:version] = version;
  end

  opts.on('-r', '--container_runtime container runtime', 'the container runtime to use. this can only be docker or cri_containerd') do |container_runtime|
    options[:container_runtime] = container_runtime;
  end

  opts.on('-c', '--cni-provider cni-provider', 'the networking provider to use') do |cni_provider|
    options[:cni_provider] = cni_provider;
  end

  opts.on('-f', '--fqdn fqdn', 'the cluster fqdn. Should match ip.') do |fqdn|
    options[:fqdn] = fqdn;
  end

  opts.on('-i', '--ip ip', 'the api ip to use. Loadbalance in production.') do |ip|
    options[:ip] = ip;
  end

  opts.on('-b', '--bootstrap-controller-ip bootstrap', 'the bootstrap controller ip address') do |bootstrap|
    options[:bootstrap_controller_ip] = bootstrap;
  end

  opts.on('-e', '--etcd-initial-cluster etcd_initial_cluster', 'members of the initial etcd cluster') do |etcd_initial_cluster|
    options[:etcd_initial_cluster] = etcd_initial_cluster;
  end

  opts.on('-t', '--etcd-ip etcd_ip', 'ip address etcd will listen on') do |etcd_ip|
    options[:etcd_ip] = etcd_ip;
  end

  opts.on('-a', '--api-address api_address', 'the ip address that kube api will listen on') do |api_address|
    options[:kube_api_advertise_address] = api_address;
  end

  opts.on('-d', '--install-dashboard dashboard', 'install the kube dashboard') do |dashboard|
    options[:install_dashboard] = dashboard;
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!


class Kube_tool
  def build_hiera(hash)
    OtherParams.create(hash[:os], hash[:version], hash[:container_runtime], hash[:cni_provider], hash[:bootstrap_controller_ip], hash[:fqdn], hash[:etcd_initial_cluster], hash[:etcd_ip],  hash[:kube_api_advertise_address], hash[:install_dashboard], hash[:kube_api_service_ip])
    PreChecks.checks
    CreateCerts.ca
    CreateCerts.api_servers(hash[:fqdn], hash[:ip], hash[:bootstrap_controller_ip], hash[:kube_api_service_ip])
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
    CleanUp.remove_files
    CleanUp.clean_yaml
  end
end

generate = Kube_tool.new

generate.build_hiera(options)
