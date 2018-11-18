require 'spec_helper'
describe 'kubernetes::config', :type => :class do
  context 'with controller => true and manage_etcd => true' do
    let(:params) do 
        {
        'kubernetes_version' => '1.10.2',        
        'container_runtime' => 'docker',
        'manage_etcd' => true,
        'etcd_version' => '3.1.12',
        'etcd_ca_key' => 'foo',
        'etcd_ca_crt' => 'foo', 
        'etcdclient_key' => 'foo',
        'etcdclient_crt' => 'foo',
        'api_server_count' => 3,
        'kubernetes_ca_crt' => 'foo',
        'kubernetes_ca_key' => 'foo',
        'discovery_token_hash' => 'foo',
        'sa_pub' => 'foo',
        'sa_key' => 'foo',
        'kube_api_advertise_address' => 'foo',
        'cni_pod_cidr' => '10.0.0.0/24',
        'etcdserver_crt' => 'foo', 
        'etcdserver_key' => 'foo', 
        'etcdpeer_crt' => 'foo', 
        'etcdpeer_key' => 'foo', 
        'etcd_peers' => ['foo'], 
        'etcd_ip' => 'foo', 
        'etcd_initial_cluster' => 'foo',  
        'token' => 'foo',     
        'apiserver_cert_extra_sans' => ['foo'],
        'apiserver_extra_arguments' => ['foo'],
        'service_cidr' => '10.96.0.0/12',
        'node_label' => 'foo',
        'cloud_provider' => 'undef',
        'cloud_config' => 'undef',        
        'kubeadm_extra_config' => {'foo' => ['bar', 'baz']},
        'kubelet_extra_config' => {'baz' => ['bar', 'foo']},
        'kubelet_extra_arguments' => ['foo'],
        'image_repository' => 'k8s.gcr.io',
        }
    end

    kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/pki/etcd']
    etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
    pki = ['ca.crt', 'ca.key','sa.pub','sa.key']

    for d in kube_dirs do
    it { should contain_file("#{d}") }
    end

    for f in etcd do
    it { should contain_file("/etc/kubernetes/pki/etcd/#{f}") }
    end

    for cert in pki do
    it { should contain_file("/etc/kubernetes/pki/#{cert}") }
    end


    it { should contain_file('/etc/systemd/system/etcd.service') }
    it { should contain_file('/etc/kubernetes/config.yaml') }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/foo:\n- bar\n- baz/) }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/kubeletConfiguration:\n  baseConfig:\n    baz:\n    - bar\n    - foo/) }
  end

  context 'with controller => true and manage_etcd => false' do
    let(:params) do 
        {
        'kubernetes_version' => '1.10.2',        
        'container_runtime' => 'docker',
        'manage_etcd' => false,
        'etcd_version' => '3.1.12',
        'etcd_ca_key' => 'foo',
        'etcd_ca_crt' => 'foo', 
        'etcdclient_key' => 'foo',
        'etcdclient_crt' => 'foo',
        'api_server_count' => 3,
        'kubernetes_ca_crt' => 'foo',
        'kubernetes_ca_key' => 'foo',
        'discovery_token_hash' => 'foo',
        'sa_pub' => 'foo',
        'sa_key' => 'foo',
        'kube_api_advertise_address' => 'foo',
        'cni_pod_cidr' => '10.0.0.0/24',
        'etcdserver_crt' => 'foo', 
        'etcdserver_key' => 'foo', 
        'etcdpeer_crt' => 'foo', 
        'etcdpeer_key' => 'foo', 
        'etcd_peers' => ['foo'], 
        'etcd_ip' => 'foo', 
        'etcd_initial_cluster' => 'foo',  
        'token' => 'foo',     
        'apiserver_cert_extra_sans' => ['foo'],
        'apiserver_extra_arguments' => ['foo'],
        'service_cidr' => '10.96.0.0/12',
        'node_label' => 'foo',
        'cloud_provider' => 'undef',
        'cloud_config' => 'undef',        
        'kubeadm_extra_config' => {'foo' => ['bar', 'baz']},
        'kubelet_extra_config' => {'baz' => ['bar', 'foo']},
        'kubelet_extra_arguments' => ['foo'],
        'image_repository' => 'k8s.gcr.io',
        }
    end

    kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/pki/etcd']
    etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
    pki = ['ca.crt', 'ca.key','sa.pub','sa.key']

    for d in kube_dirs do
    it { should contain_file("#{d}") }
    end

    for f in etcd do
    it { should_not contain_file("/etc/kubernetes/pki/etcd/#{f}") }
    end

    for cert in pki do
    it { should contain_file("/etc/kubernetes/pki/#{cert}") }
    end


    it { should_not contain_file('/etc/systemd/system/etcd.service') }
    it { should contain_file('/etc/kubernetes/config.yaml') }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/foo:\n- bar\n- baz/) }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/kubeletConfiguration:\n  baseConfig:\n    baz:\n    - bar\n    - foo/) }
  end
end
