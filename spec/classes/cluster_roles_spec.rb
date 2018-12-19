require 'spec_helper'
describe 'kubernetes::cluster_roles', :type => :class do
    let(:facts) do
      {
        :kernel           => 'Linux',
        :networking       => {
          :hostname => 'foo',
        },
        :os               => {
          :family => "Debian",
          :name    => 'Ubuntu',
          :release => {
            :full => '16.04',
          },
          :distro => {
            :codename => "xenial",
          },
        },
      }
    end
  context 'with controller => true' do
    let(:params) do 
        { 
          'controller' => true, 
          'worker' => false,
          'etcd_ip' => 'foo',           
          'etcd_ca_key' => 'foo',
          'etcd_ca_crt' => 'foo', 
          'etcdclient_key' => 'foo',
          'etcdclient_crt' => 'foo',
          'api_server_count' => 3,
          'discovery_token_hash' => 'foo',
          'kube_api_advertise_address' => 'foo',
          'cni_pod_cidr' => '10.0.0.0/24',
          'token' => 'foo',
          'etcd_initial_cluster' => 'foo',
          'controller_address' => '172.17.10.101',  
          'node_name' => 'foo',
          'container_runtime' => 'docker',     
        } 
    end

    it { should contain_kubernetes__kubeadm_init('foo') }
  end

  context 'with worker => true' do
    let(:params) do 
        { 
          'controller' => false, 
          'worker' => true,
          'etcd_ip' => 'foo',           
          'etcd_ca_key' => 'foo',
          'etcd_ca_crt' => 'foo', 
          'etcdclient_key' => 'foo',
          'etcdclient_crt' => 'foo',
          'api_server_count' => 3,
          'discovery_token_hash' => 'foo',
          'kube_api_advertise_address' => 'foo',
          'cni_pod_cidr' => '10.0.0.0/24',
          'token' => 'foo',
          'etcd_initial_cluster' => 'foo',   
          'controller_address' => '172.17.10.101',  
          'node_name' => 'foo',
          'container_runtime' => 'docker',  
          # 'docker_package_name' => 'docker-engine',   
        } 
    end

    it { should contain_kubernetes__kubeadm_join('foo') }
  end
end
