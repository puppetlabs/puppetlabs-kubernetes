class PreChecks
  def PreChecks.checks
    system('which cfssl')
    x =  $?.success?
    if x ==false
    puts "Warning... This requires CFSSL to be installed"
    puts "Please follow the instructions here https://github.com/cloudflare/cfssl"
    puts "Make sure the CFSSL binary is in your $PATH"
    exit 1
    end 
  end
end 
