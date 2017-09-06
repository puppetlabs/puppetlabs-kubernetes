require 'yaml'
require 'base64'
require 'date'
require 'securerandom'

class CreateToken
  
  def CreateToken.bootstrap
    puts "Creating bootstrap token"
    token = SecureRandom.hex(8)
    key = SecureRandom.hex(3)
    full_token = "#{key}.#{token}"
    data = Hash.new
    data['kubernetes::bootstrap_token'] = full_token
    data['kubernetes::bootstrap_token_name'] = "bootstrap-token-#{key}"
    data['kubernetes::bootstrap_token_description'] = Base64.strict_encode64("The default bootstrap token passed to the cluster via Puppet.")
    data['kubernetes::bootstrap_token_id'] = Base64.strict_encode64(key)
    data['kubernetes::bootstrap_token_secret'] = Base64.strict_encode64(full_token)
    data['kubernetes::bootstrap_token_expiration'] = "MjAyNy0wMy0xMFQwMzoyMjoxMVoNCg=="
    data['kubernetes::bootstrap_token_usage_bootstrap_authentication'] = Base64.strict_encode64("true")
    data['kubernetes::bootstrap_token_usage_bootstrap_signing'] = Base64.strict_encode64("true")
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end
end

