#!/usr/bin/env ruby

require 'optparse'
require_relative 'kube_tool/pre_checks.rb'
require_relative 'kube_tool/create_certs.rb'
require_relative 'kube_tool/clean_up.rb'
require_relative 'kube_tool/other_params.rb'

options = {:os                         => nil,
           :version                    => nil,
           :container_runtime          => nil,
           :cni_provider               => nil,
           :cni_provider_version       => nil,
           :etcd_initial_cluster       => nil,
           :kube_api_advertise_address => nil,
      	   :install_dashboard          => nil,
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

  opts.on('-c', '--cni-provider cni-provider', 'the networking provider to use, flannel, weave, calico or cilium are supported') do |cni_provider|
    options[:cni_provider] = cni_provider;
  end
  opts.on('-p', '--cni-provider-version [cni_provider_version]', 'the networking provider version to use, calico and cilium will use this to reference the correct deployment downloadlink') do |cni_provider_version|
    options[:cni_provider_version] = cni_provider_version;
  end

  opts.on('-i', '--etcd-initial-cluster etcd-initial-cluster', 'the list of servers in the etcd cluster') do | etcd_initial_cluster |
    options[:etcd_initial_cluster] = etcd_initial_cluster
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
    OtherParams.create( hash[:os], hash[:version], hash[:container_runtime], hash[:cni_provider], hash[:cni_provider_version], hash[:etcd_initial_cluster], hash[:etcd_ip], hash[:kube_api_advertise_address], hash[:install_dashboard])
    PreChecks.checks
    CreateCerts.etcd_ca
    CreateCerts.etcd_clients
    CreateCerts.etcd_certificates( hash[:etcd_initial_cluster])
    CreateCerts.kube_ca
    CreateCerts.kube_front_proxy_ca
    CreateCerts.sa    
    CleanUp.remove_files
    CleanUp.clean_yaml( hash[:os])
  end
end

generate = Kube_tool.new

generate.build_hiera(options)
