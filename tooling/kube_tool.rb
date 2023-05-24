#!/usr/bin/env ruby

require 'slop'
require_relative 'kube_tool/pre_checks.rb'
require_relative 'kube_tool/create_certs.rb'
require_relative 'kube_tool/clean_up.rb'
require_relative 'kube_tool/other_params.rb'

# Kube Tool
class Kube_tool
  def self.parse_args
    begin
      opts = Slop.parse do |o|
        o.string '-o', '--os', 'The OS that Kubernetes will run on', default: ENV['OS']
        o.string '-v', '--version', 'The Kubernetes version to install', default: ENV['VERSION']
        o.string '-r', '--container_runtime', 'The container runtime to use. This can only be "docker" or "cri_containerd"', default: ENV['CONTAINER_RUNTIME']
        o.string '-c', '--cni_provider', 'The networking provider to use, flannel, weave, calico, calico-tigera or cilium are supported', default: ENV['CNI_PROVIDER']
        o.string '-p', '--cni_provider_version', 'The networking provider version to use, calico and cilium will use this to reference the correct deployment download link', 
                 default: ENV['CNI_PROVIDER_VERSION']
        o.string '-t', '--etcd_ip', 'The IP address etcd will listen on', default: ENV['ETCD_IP']
        o.string '-i', '--etcd_initial_cluster', 'The list of servers in the etcd cluster', default: ENV['ETCD_INITIAL_CLUSTER']
        o.string '-a', '--api_address', 'The IP address (or fact) that kube api will listen on', default: ENV['KUBE_API_ADVERTISE_ADDRESS']
        o.int '-b', '--key_size', 'Specifies the number of bits in the key to create', default: ENV['KEY_SIZE'].to_i
        o.int '--ca_algo', 'Algorithm to generate CA certificates, default: ecdsa', default: ENV['CA_ALGO']
        o.int '--sa_size', 'Service account key size', default: ENV['SA_SIZE'].to_i
        o.bool '-d', '--install_dashboard', 'Whether install the kube dashboard', default: ENV['INSTALL_DASHBOARD']
        o.on '-h','--help', 'print the help' do
          puts o
          exit
        end
      end

      options = opts.to_hash
      options[:key_size] = 256 if options[:key_size] < 1
      options[:sa_size] = 2048 if options[:sa_size] < 1
      options[:ca_algo] ||= 'ecdsa'
      options[:container_runtime] ||= 'cri_containerd'
      options[:version] ||= '1.25.4'
      options[:os] ||= 'Debian'
      if options[:etcd_initial_cluster].nil?
        abort('Please provide IP addresses for etcd initial cluster -i/--etcd_initial_cluster (ENV ETCD_INITIAL_CLUSTER)')
      end
      puts options
      return options
    rescue Slop::Error => e
      puts "ERROR: #{e.message}"
      exit 1
    end
  end

  def self.build_hiera(opts)
    OtherParams.create(opts)
    PreChecks.checks
    certs = CreateCerts.new(opts)
    certs.etcd_ca
    certs.etcd_clients
    certs.etcd_certificates
    certs.kube_ca
    certs.kube_front_proxy_ca
    certs.sa
    CleanUp.remove_files
    CleanUp.clean_yaml(opts[:os])
  end
end
Kube_tool.build_hiera(Kube_tool.parse_args)
