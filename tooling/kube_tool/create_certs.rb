require 'fileutils'
require 'openssl'
require 'json'
require 'base64'

#TODO fix repeatitive code after inital internal release

class CreateCerts
  def CreateCerts.etcd_ca
    puts "Creating etcd ca"
    files = ['ca-conf.json', 'ca-csr.json', 'ca-key.pem', 'ca-key.pem']
    files.each do |x|
      if File.exist?(x)
        FileUtils.rm_f(x)
      end
    end
    csr = { "CN": "etcd", "key": {"algo": "rsa", "size": 2048 }}
    conf = { "signing": { "default": { "expiry": "43800h" }, "profiles": { "server": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] }, "client": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "client auth" ] }, "peer": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] } } } }
    File.open("ca-csr.json", "w+") { |file| file.write(csr.to_json) }
    File.open("ca-conf.json", "w+") { |file| file.write(conf.to_json) }
    system('cfssl gencert -initca ca-csr.json | cfssljson -bare ca')
    FileUtils.rm_f('ca.csr')
    data = Hash.new
    cer = File.read("ca.pem")
    key = File.read("ca-key.pem")
    data['kubernetes::etcd_ca_crt'] = cer
    data['kubernetes::etcd_ca_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.etcd_clients
    puts "Creating etcd client certs"
    csr = { "CN": "client", "hosts": [""], "key": { "algo": "rsa", "size": 2048 } }
    File.open("kube-etcd-csr.json", "w+") { |file| file.write(csr.to_json) }
    system("cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile client kube-etcd-csr.json | cfssljson -bare client")
    FileUtils.rm_f('kube-etcd-csr.csr')
    data = Hash.new
    cer = File.read("client.pem")
    key = File.read("client-key.pem")
    data['kubernetes::etcdclient_crt'] = cer
    data['kubernetes::etcdclient_key'] = key
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) }
  end

  def CreateCerts.etcd_certificates(etcd_initial_cluster)
    etcd_servers = etcd_initial_cluster.split(",")
    etcd_server_ips = []
    etcd_servers.each do | servers |
      server = servers.split(":")
      etcd_server_ips.push(server[1])
    end

    etcd_servers.each do | servers |
      server = servers.split(":")
      hostname = server[0]
      ip = server[1]
      if File.exist?("#{hostname}.yaml")
        FileUtils.rm_f("#{hostname}.yaml")
      end  
        puts "Creating etcd peer and server certificates"
        csr = { "CN": "etcd-#{hostname}", "hosts": etcd_server_ips, "key": { "algo": "rsa", "size": 2048 }}
        File.open("config.json", "w+") { |file| file.write(csr.to_json) }
        system("cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile server --hostname=#{etcd_server_ips * ","},#{hostname} config.json | cfssljson -bare #{hostname}-server")
        system("cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile peer --hostname=#{ip},#{hostname} config.json | cfssljson -bare #{hostname}-peer")
        system("cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-conf.json -profile client --hostname=#{ip},#{hostname} config.json | cfssljson -bare #{hostname}-client")
        FileUtils.rm_f('etcd-server.csr')
        data = Hash.new
        cer_server = File.read("#{hostname}-server.pem")
        key_server = File.read("#{hostname}-server-key.pem")
        cer_peer = File.read("#{hostname}-peer.pem")
        key_peer = File.read("#{hostname}-peer-key.pem")
        cer_client = File.read("#{hostname}-client.pem")
        key_client = File.read("#{hostname}-client-key.pem")
        data['kubernetes::etcdserver_crt'] = cer_server
        data['kubernetes::etcdserver_key'] = key_server
        data['kubernetes::etcdpeer_crt'] = cer_peer
        data['kubernetes::etcdpeer_key'] = key_peer
        data['kubernetes::etcdclient_crt'] = cer_client
        data['kubernetes::etcdclient_key'] = key_client
        File.open("#{hostname}.yaml", "a") { |file| file.write(data.to_yaml) }
    end
  end

  def CreateCerts.kube_ca
    puts "Creating kube ca"
    files = ['ca-conf.json', 'ca-csr.json', 'ca-key.pem', 'ca-key.pem']
    files.each do |x|
      if File.exist?(x)
        FileUtils.rm_f(x)
      end
    end
    csr = { "CN": "kubernetes", "key": {"algo": "rsa", "size": 2048 }}
    conf = { "signing": { "default": { "expiry": "43800h" }, "profiles": { "server": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] }, "client": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "client auth" ] }, "peer": { "expiry": "43800h", "usages": [ "signing", "key encipherment", "server auth", "client auth" ] } } } }
    File.open("ca-csr.json", "w+") { |file| file.write(csr.to_json) }
    File.open("ca-conf.json", "w+") { |file| file.write(conf.to_json) }
    system('cfssl gencert -initca ca-csr.json | cfssljson -bare ca')
    system("openssl x509 -pubkey -in ca.pem | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' > discovery_token_hash")
    FileUtils.rm_f('ca.csr')
    data = Hash.new
    cer = File.read("ca.pem")
    key = File.read("ca-key.pem")
    discovery_token_hash = File.read("discovery_token_hash")
    data['kubernetes::kubernetes_ca_crt'] = cer
    data['kubernetes::kubernetes_ca_key'] = key
    data['kubernetes::discovery_token_hash'] = discovery_token_hash
    FileUtils.rm_f('discovery_token_hash.csr')
    File.open("kubernetes.yaml", "a") { |file| file.write(data.to_yaml) } 
  end

  def CreateCerts.kube_front_proxy_ca
    puts "Creating kube front-proxy ca"
    files = ['front-proxy-ca-conf.json', 'front-proxy-ca-csr.json', 'front-proxy-ca-key.pem', 'front-proxy-ca-key.pem']
    files.each do |x|
      if File.exist?(x)
        FileUtils.rm_f(x)
      end
    end
    csr = { "CN": "front-proxy-ca", "key": {"algo": "rsa", "size": 2048 }}
    conf = { "signing": { "default": { "expiry": "87600h" }}}
    File.open("front-proxy-ca-csr.json", "w+") { |file| file.write(csr.to_json) }
    File.open("front-proxy-ca-conf.json", "w+") { |file| file.write(conf.to_json) }
    system('cfssl gencert -initca front-proxy-ca-csr.json | cfssljson -bare front-proxy-ca')
    FileUtils.rm_f('front-proxy-ca.csr')
    data = Hash.new
    cer = File.read("front-proxy-ca.pem")
    key = File.read("front-proxy-ca-key.pem")
    data['kubernetes::kubernetes_front_proxy_ca_crt'] = cer
    data['kubernetes::kubernetes_front_proxy_ca_key'] = key
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


end


