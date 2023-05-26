#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'json'
require 'puppet'
require 'openssl'

def delete_rbac_authorization_v1_collection_cluster_role(*args)
  header_params = {}

  params = args[0][1..].split(',')

  arg_hash = {}
  params.each do |param|
    mapValues = param.split(':', 2)
    mapValues[1].tr! ';', ',' if mapValues[1].include?(';')
    arg_hash[mapValues[0][1..-2]] = mapValues[1][1..-2]
  end

  # Remove task name from arguments - should contain all necessary parameters for URI
  arg_hash.delete('_task')
  operation_verb = 'Delete'

  query_params, body_params, path_params = format_params(arg_hash)

  uri_string = "#{arg_hash['kube_api']}/apis/rbac.authorization.k8s.io/v1/clusterroles" % path_params

  uri_string = "#{uri_string}?#{to_query(query_params)}" if query_params

  header_params['Content-Type'] = 'application/json' # first of #{parent_consumes}

  header_params['Authentication'] = "Bearer #{arg_hash['token']}" if arg_hash['token']

  uri = URI(uri_string)

  verify_mode = OpenSSL::SSL::VERIFY_NONE
  verify_mode = OpenSSL::SSL::VERIFY_PEER if arg_hash['ca_file']

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode: verify_mode, ca_file: arg_hash['ca_file']) do |http|
    case operation_verb
    when 'Get'
      req = Net::HTTP::Get.new(uri)
    when 'Put'
      req = Net::HTTP::Put.new(uri)
    when 'Delete'
      req = Net::HTTP::Delete.new(uri)
    when 'Post'
      req = Net::HTTP::Post.new(uri)
    end

    header_params.each { |x, v| req[x] = v } unless header_params.empty?

    unless body_params.empty?
      req.body = if body_params.key?('file_content')
                   body_params['file_content']
                 else
                   body_params.to_json
                 end
    end

    Puppet.debug("URI is (#{operation_verb}) #{uri} headers are #{header_params}")
    response = http.request req # Net::HTTPResponse object
    Puppet.debug("response code is #{response.code} and body is #{response.body}")
    success = response.is_a? Net::HTTPSuccess
    Puppet.debug("Called (#{operation_verb}) endpoint at #{uri}, success was #{success}")
    response
  end
end

def to_query(hash)
  if hash
    return_value = hash.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }
    return return_value unless return_value.nil?
  end
  ''
end

def op_param(name, inquery, paramalias, namesnake)
  { name: name, location: inquery, paramalias: paramalias, namesnake: namesnake }
end

def format_params(key_values)
  query_params = {}
  body_params = {}
  path_params = {}

  key_values.each do |key, value|
    next unless value.include?('=>')

    Puppet.debug("Running hash from string on #{value}")
    value.gsub!('=>', ':')
    value.tr!("'", '"')
    key_values[key] = JSON.parse(value)
    Puppet.debug("Obtained hash #{key_values[key].inspect}")
  end

  if key_values.key?('body') && File.file?(key_values['body'])
    body_params['file_content'] = if key_values['body'].include?('json')
                                    File.read(key_values['body'])
                                  else
                                    JSON.pretty_generate(YAML.load_file(key_values['body']))
                                  end
  end

  op_params = [
    op_param('aggregationrule', 'body', 'aggregation_rule', 'aggregationrule'),
    op_param('apiversion', 'body', 'api_version', 'apiversion'),
    op_param('continue', 'query', 'continue', 'continue'),
    op_param('fieldSelector', 'query', 'field_selector', 'field_selector'),
    op_param('kind', 'body', 'kind', 'kind'),
    op_param('labelSelector', 'query', 'label_selector', 'label_selector'),
    op_param('limit', 'query', 'limit', 'limit'),
    op_param('metadata', 'body', 'metadata', 'metadata'),
    op_param('pretty', 'query', 'pretty', 'pretty'),
    op_param('resourceVersion', 'query', 'resource_version', 'resource_version'),
    op_param('rules', 'body', 'rules', 'rules'),
    op_param('timeoutSeconds', 'query', 'timeout_seconds', 'timeout_seconds'),
    op_param('watch', 'query', 'watch', 'watch'),
  ]
  op_params.each do |i|
    location = i[:location]
    name     = i[:name]
    paramalias = i[:paramalias]
    name_snake = i[:namesnake]
    if location == 'query'
      query_params[name] = key_values[name_snake] unless key_values[name_snake].nil?
      query_params[name] = ENV.fetch("azure__#{name_snake}", nil) unless ENV["<no value>_#{name_snake}"].nil?
    elsif location == 'body'
      body_params[name] = key_values[name_snake] unless key_values[name_snake].nil?
      body_params[name] = ENV.fetch("azure_#{name_snake}", nil) unless ENV["<no value>_#{name_snake}"].nil?
    else
      path_params[name_snake.to_sym] = key_values[name_snake] unless key_values[name_snake].nil?
      path_params[name_snake.to_sym] = ENV.fetch("azure__#{name_snake}", nil) unless ENV["<no value>_#{name_snake}"].nil?
    end
  end

  [query_params, body_params, path_params]
end

def task
  # Get operation parameters from an input JSON
  params = $stdin.read
  result = delete_rbac_authorization_v1_collection_cluster_role(params)
  raise result.body unless result.is_a? Net::HTTPSuccess

  puts result.body
rescue StandardError => e
  result = {}
  result[:_error] = {
    msg: e.message,
    kind: 'puppetlabs-kubernetes/error',
    details: { class: e.class.to_s }
  }
  puts result
  exit 1
end

task
