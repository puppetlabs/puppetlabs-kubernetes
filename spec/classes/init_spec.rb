require 'spec_helper'
describe 'kubernetes', :type => :class do
  let(:facts) do
    {
      :kernel           => 'Linux',
      :lsbdistcodename  => 'xenial',
      :osfamily         => 'Debian',
      :operatingsystem  => 'Ubuntu',
      :os               => {
        :name    => 'Ubuntu',
        :release => {
          :full => '16.04',
        },
       
      },
    }
  end

  context 'with controller => true and worker => true' do
    let(:params) do
      { 
        'controller' => true,
        'worker' => true,
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
        'controller_address' => '172.17.10.101:6443',
        'cloud_provider' => :undef,
        'token' => 'foo',
        'create_repos' => true,
        'disable_swap' => true,
        
      }
    end

    it { should compile.and_raise_error(/A node can not be both a controller and a node/) }
   end

  context 'with controller => true' do
    let(:params) do
      { 
        'controller' => true,
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
        'controller_address' => '172.17.10.101:6443',  
        'cloud_provider' => :undef,  
        'token' => 'foo',
        'disable_swap' => true,
                         
      }
    end

    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { should contain_class('kubernetes::config')}
    it { should contain_class('kubernetes::service')}
    it { should contain_class('kubernetes::cluster_roles')}
    it { should contain_class('kubernetes::kube_addons')}
  end

  context 'with worker => true' do
    let(:params) do
      { 
        'worker' => true,
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
        'controller_address' => '172.17.10.101:6443',   
        'cloud_provider' => :undef,
        'token' => 'foo',
        'disable_swap' => true,
                
      }
    end

    it { should contain_class('kubernetes') }
    it { should contain_class('kubernetes::repos') }
    it { should contain_class('kubernetes::packages')}
    it { should contain_class('kubernetes::service')}
  end
end
