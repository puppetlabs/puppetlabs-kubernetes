require 'fileutils'
require 'openssl'
require 'json'

#TODO fix repeatitive code after inital internal release

class CreateCerts
  def CreateCerts.ca
    puts "Creating root ca"
    files = ['ca-conf.json', 'ca-csr.json', 'ca-key.pem', 'ca-key.pem']
    files.each do |x|  
      if File.exist?(x)
        FileUtils.rm_f(x)
      end
    end 
    csr = { "CN": "kubernetes", "key": { "algo": "rsa", "size": 2048 } }
    conf = { "signing": { "default": { "expiry": "43800h" }, "profiles": { "server": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] }, "client": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "client auth" ] }, "peer": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] } } } }
    File.open("ca-csr.json", "w+") { |file| file.write(csr.to_json) }
    File.open("ca-conf.json", "w+") { |file| file.write(conf.to_json) }
    system('cfssl gencert -initca ca-csr.json | cfssljson -bare ca')
    FileUtils.rm_f('ca.csr')
    data = Hash.new
    cer = File.read("ca.pem")
    key = File.read("ca-key.pem")
    data['kubernetes::ca_crt'] = cer
    data['kubernetes::ca_key'] = key
    data['kubernetes::certificate_authority_data'] = Base64.strict_encode64(cer)
    File.open("kubernetes.yaml", "w+") { |file| file.write(data.to_yaml) }
  end	  

  def CreateCerts.api_servers(fqdn, ip)
    puts "Creating api server certs"
    dns = fqdn
    ip = ip

    csr = { "CN": "kube-apiserver", "hosts": [  "kube-master", "kubernetes", "kubernetes.default", "kubernetes.default.svc", "kubernetes.default.svc.cluster.local", "cluster.local", dns,  ip, "10.96.0.1"  ], "key": { "algo": "rsa", "size": 2048 }}
    File.open("kube-api-csr.json", "w+") { |file| file.write(csr.to_json) }  
    system("cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server kube-api-csr.json | cfssljson -bare apiserver")
    FileUtils.rm_f('kube-api-csr.csr')
    data = Hash.new
    cer = File.read("apiserver.pem")
    key = File.read("apiserver-key.pem")
    data['kubernetes::apiserver_crt'] = cer
    data['kubernetes::apiserver_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end 

  def CreateCerts.sa
    puts "Creating service account certs"
    key = OpenSSL::PKey::RSA.new 2048
    open 'sa-key.pem', 'w' do |io| 
      io.write key.to_pem 
    end
    open 'sa-pub.pem', 'w' do |io| 
      io.write key.public_key.to_pem 
    end
    data = Hash.new
    cer = File.read("sa-pub.pem")
    key = File.read("sa-key.pem")
    data['kubernetes::sa_pub'] = cer
    data['kubernetes::sa_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.admin
    puts "Creating admin cert"
    csr = { "CN": " kubernetes-admin", "key": { "algo": "rsa", "size": 2048 }, "names": [ { "O": "system:masters" } ] }
    File.open("kube-admin-csr.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile client kube-admin-csr.json | cfssljson -bare admin')
    data = Hash.new
    cer = File.read("admin.pem")
    key = File.read("admin-key.pem")
    data['kubernetes::client_certificate_data_admin'] = Base64.strict_encode64(cer)
    data['kubernetes::client_key_data_admin'] = Base64.strict_encode64(key)
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.apiserver_kubelet_client
    puts "Creating api server kubelet client certs"
    csr = { "CN": "kube-apiserver-kubelet-client", "key": { "algo": "rsa", "size": 2048 }, "names": [ { "O": "system:masters" } ] }
    File.open("apiserver-kubelet-client.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server apiserver-kubelet-client.json | cfssljson -bare apiserver_kubelet_client')
    data = Hash.new
    cer = File.read("apiserver_kubelet_client.pem")
    key = File.read("apiserver_kubelet_client-key.pem")
    data['kubernetes::apiserver_kubelet_client_crt'] = cer
    data['kubernetes::apiserver_kubelet_client_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.front_proxy_ca
    puts "Creating front proxy ca certs"
    csr = { "CN": "kubernetes", "key": { "algo": "rsa", "size": 2048 } }
    conf = { "signing": { "default": { "expiry": "43800h" }, "profiles": { "server": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] }, "client": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "client auth" ] }, "peer": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] } } } }
    File.open("front-proxy-ca.json", "w+") { |file| file.write(csr.to_json) }
    File.open("front-proxy-ca-conf.json", "w+") { |file| file.write(conf.to_json) }
    system('cfssl gencert -initca ca-csr.json | cfssljson -bare front-proxy-ca')
    data = Hash.new
    cer = File.read("front-proxy-ca.pem")
    key = File.read("front-proxy-ca-key.pem")
    data['kubernetes::front_proxy_ca_crt'] = cer
    data['kubernetes::front_proxy_ca_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.front_proxy_client
    puts "Creating front proxy client certs"
    csr = { "CN": "front-proxy-client", "key": { "algo": "rsa", "size": 2048 } }
    File.open("front-proxy-client.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server  front-proxy-client.json | cfssljson -bare front-proxy-client')
    data = Hash.new
    cer = File.read("front-proxy-client.pem")
    key = File.read("front-proxy-client-key.pem")
    data['kubernetes::front_proxy_client_crt'] = cer
    data['kubernetes::front_proxy_client_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.system_node
    puts "Creating system node certs"
    csr = { "CN": "system:node:kube-controller", "key": { "algo": "rsa", "size": 2048 }, "names": [ { "O": "system:nodes" } ] }
    File.open("system-node.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server system-node.json | cfssljson -bare system-node')
    data = Hash.new
    cer = File.read("system-node.pem")
    key = File.read("system-node-key.pem")
    data['kubernetes::client_certificate_data_controller'] = Base64.strict_encode64(cer)
    data['kubernetes::client_key_data_controller'] = Base64.strict_encode64(key)
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }    
  end    

  def CreateCerts.kube_controller_manager
    puts "Creating kube controller manager certs"	  
    csr = { "CN": "system:kube-controller-manager", "key": { "algo": "rsa", "size": 2048 }, "names": [ { "O": "system:masters" } ] }
    File.open("kube-controller-manager.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server kube-controller-manager.json | cfssljson -bare kube-controller-manager')
    data = Hash.new
    cer = File.read("kube-controller-manager.pem")
    key = File.read("kube-controller-manager-key.pem")
    data['kubernetes::client_certificate_data_controller_manager'] = Base64.strict_encode64(cer)
    data['kubernetes::client_key_data_controller_manager'] = Base64.strict_encode64(key)
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end  

  def CreateCerts.kube_scheduler
    puts "Creating kube scheduler certs"
    csr = { "CN": "system:kube-scheduler", "key": { "algo": "rsa", "size": 2048 } }
    File.open("kube-scheduler.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server kube-scheduler.json | cfssljson -bare kube-scheduler')
    data = Hash.new
    cer = File.read("kube-scheduler.pem")
    key = File.read("kube-scheduler-key.pem")
    data['kubernetes::client_certificate_data_scheduler'] = Base64.strict_encode64(cer)
    data['kubernetes::client_key_data_scheduler'] = Base64.strict_encode64(key)
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }  
  end   

  def CreateCerts.kube_workers
    puts "Creating kube worker certs"
    csr = { "CN": "system:node:kube-workers", "key": { "algo": "rsa", "size": 2048 }, "names": [ { "O": "system:nodes" } ] }
    File.open("kube-workers.json", "w+") { |file| file.write(csr.to_json) }
    system('cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server kube-workers.json | cfssljson -bare kube-workers')
    data = Hash.new
    cer = File.read("kube-workers.pem")
    key = File.read("kube-workers-key.pem")
    data['kubernetes::client_certificate_data_worker'] = Base64.strict_encode64(cer)
    data['kubernetes::client_key_data_worker'] = Base64.strict_encode64(key)
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end	  
end

