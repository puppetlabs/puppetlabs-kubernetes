require 'shellwords'
#
# kubeadm_join_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of kubeadm init flags
  newfunction(:kubeadm_join_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << "'#{opts['controller_address']}'" if opts['controller_address'] && opts['controller_address'].to_s != 'undef'
    # --config is exclusive with --discovery-file, so if --discovery-file is present, don't use --config
    flags << "--config '#{opts['config']}'" if opts['config'] && opts['config'].to_s != 'undef' && !(opts['discovery_file'] && opts['discovery_file'].to_s != 'undef')
    flags << "--cri-socket '#{opts['cri_socket']}'" if opts['cri_socket'] && opts['cri_socket'].to_s != 'undef'
    flags << "--discovery-file '#{opts['discovery_file']}'" if opts['discovery_file'] && opts['discovery_file'].to_s != 'undef'
    flags << "--discovery-token '#{opts['discovery_token']}'" if opts['discovery_token'] && opts['discovery_token'].to_s != 'undef'
    flags << "--discovery-token-ca-cert-hash 'sha256:#{opts['ca_cert_hash']}'" if opts['ca_cert_hash'] && opts['ca_cert_hash'].to_s != 'undef'
    flags << "--discovery-token-unsafe-skip-ca-verification '#{opts['skip_ca_verification']}'" if opts['skip_ca_verification']
    flags << "--feature-gates '#{opts['feature_gates'].join(',')}'" if opts['feature_gates'] && opts['feature_gates'].to_s != 'undef'
    flags << "--ignore-preflight-errors '#{opts['ignore_preflight_errors'].join(',')}'" if opts['ignore_preflight_errors'] && opts['ignore_preflight_errors'].to_s != 'undef'
    flags << "--node-name '#{opts['node_name']}'" if opts['node_name'] && opts['node_name'].to_s != 'undef'
    flags << "--token '#{opts['token']}'" if opts['token'] && opts['token'].to_s != 'undef'

    flags.flatten.join(' ')
  end
end
