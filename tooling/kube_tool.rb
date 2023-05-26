#!/usr/bin/env ruby
# frozen_string_literal: true

require 'slop'
require_relative 'kube_tool/pre_checks'
require_relative 'kube_tool/create_certs'
require_relative 'kube_tool/clean_up'
require_relative 'kube_tool/other_params'

# Kube Tool
class Kube_tool
  def self.parse_args
    opts = Slop.parse do |o|
      o.string '-o', '--os', 'The OS that Kubernetes will run on', default: ENV.fetch('OS', nil)
      o.string '-v', '--version', 'The Kubernetes version to install', default: ENV.fetch('VERSION', nil)
      o.string '-r', '--container_runtime', 'The container runtime to use. This can only be "docker" or "cri_containerd"', default: ENV.fetch('CONTAINER_RUNTIME', nil)
      o.string '-c', '--cni_provider', 'The networking provider to use, flannel, weave, calico, calico-tigera or cilium are supported', default: ENV.fetch('CNI_PROVIDER', nil)
      o.string '-p', '--cni_provider_version', 'The networking provider version to use, calico and cilium will use this to reference the correct deployment download link',
               default: ENV.fetch('CNI_PROVIDER_VERSION', nil)
      o.string '-t', '--etcd_ip', 'The IP address etcd will listen on', default: ENV.fetch('ETCD_IP', nil)
      o.string '-i', '--etcd_initial_cluster', 'The list of servers in the etcd cluster', default: ENV.fetch('ETCD_INITIAL_CLUSTER', nil)
      o.string '-a', '--api_address', 'The IP address (or fact) that kube api will listen on', default: ENV.fetch('KUBE_API_ADVERTISE_ADDRESS', nil)
      o.int '-b', '--key_size', 'Specifies the number of bits in the key to create', default: ENV['KEY_SIZE'].to_i
      o.int '--ca_algo', 'Algorithm to generate CA certificates, default: ecdsa', default: ENV.fetch('CA_ALGO', nil)
      o.int '--sa_size', 'Service account key size', default: ENV['SA_SIZE'].to_i
      o.bool '-d', '--install_dashboard', 'Whether install the kube dashboard', default: ENV.fetch('INSTALL_DASHBOARD', nil)
      o.on '-h', '--help', 'print the help' do
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
    abort('Please provide IP addresses for etcd initial cluster -i/--etcd_initial_cluster (ENV ETCD_INITIAL_CLUSTER)') if options[:etcd_initial_cluster].nil?
    puts options
    options
  rescue Slop::Error => e
    puts "ERROR: #{e.message}"
    exit 1
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
