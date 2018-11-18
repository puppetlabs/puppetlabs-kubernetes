require 'spec_helper'
describe 'kubernetes::service', :type => :class do
  let(:facts) do
    {
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

  context 'with controller => true and container_runtime => cri_containerd and manage_etcd => true' do
    let(:pre_condition) { 'class {"kubernetes::config":
        kubernetes_version => "1.10.2",
        container_runtime => "cri_containerd",
        manage_etcd => true,
        etcd_version => "3.1.12",
        etcd_ca_key => "foo",
        etcd_ca_crt => "foo", 
        etcdclient_key => "foo",
        etcdclient_crt => "foo",
        api_server_count => 3,
        kubernetes_ca_crt => "foo",
        kubernetes_ca_key => "foo",
        discovery_token_hash => "foo",
        sa_pub => "foo",
        sa_key => "foo",
        kube_api_advertise_address => "foo",
        cni_pod_cidr => "10.0.0.0/24",
        etcdserver_crt => "foo", 
        etcdserver_key => "foo", 
        etcdpeer_crt => "foo", 
        etcdpeer_key => "foo", 
        etcd_peers => ["foo"], 
        etcd_ip => "foo", 
        etcd_initial_cluster => "foo",  
        token => "foo",     
        apiserver_cert_extra_sans => ["foo"],
        apiserver_extra_arguments => ["foo"],
        service_cidr => "10.96.0.0/12",
        node_label => "foo",
        cloud_provider => ":undef",
        cloud_config => ":undef",        
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
      {
        'container_runtime' => 'cri_containerd',
        'controller' => true,
        'cloud_provider' => ':undef',
        'manage_docker' => true,
        'manage_etcd' => true,
      }
    end
   it { should contain_file('/etc/systemd/system/kubelet.service.d')}
   it { should contain_file('/etc/systemd/system/kubelet.service.d/0-containerd.conf')}
   it { should contain_file('/etc/systemd/system/containerd.service')}   
   it { should contain_exec('kubernetes-systemd-reload')}
   it { should contain_service('containerd')}
   it { should contain_service('etcd')}
  end

  context 'with controller => true and container_runtime => docker and manage_docker => true and manage_etcd => false' do
    let(:pre_condition) { 'class {"kubernetes::config":
        kubernetes_version => "1.10.2",
        container_runtime => "docker",
        manage_etcd => false,
        etcd_version => "3.1.12",
        etcd_ca_key => "foo",
        etcd_ca_crt => "foo", 
        etcdclient_key => "foo",
        etcdclient_crt => "foo",
        api_server_count => 3,
        kubernetes_ca_crt => "foo",
        kubernetes_ca_key => "foo",
        discovery_token_hash => "foo",
        sa_pub => "foo",
        sa_key => "foo",
        kube_api_advertise_address => "foo",
        cni_pod_cidr => "10.0.0.0/24",
        etcdserver_crt => "foo", 
        etcdserver_key => "foo", 
        etcdpeer_crt => "foo", 
        etcdpeer_key => "foo", 
        etcd_peers => ["foo"], 
        etcd_ip => "foo", 
        etcd_initial_cluster => "foo",  
        token => "foo",     
        apiserver_cert_extra_sans => ["foo"],
        apiserver_extra_arguments => ["foo"],
        service_cidr => "10.96.0.0/12",
        node_label => "foo",
        cloud_provider => ":undef",
        cloud_config => ":undef",        
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
      {
        'container_runtime' => 'docker',
        'controller' => true,
        'cloud_provider' => ':undef',
        'manage_docker' => true,
        'manage_etcd' => false,
      }
    end
    it { should contain_service('docker')}
    it { should_not contain_service('etcd')}
  end
  
  context 'with controller => true and container_runtime => docker and manage_docker => false and manage_etcd => true' do
    let(:pre_condition) { 'class {"kubernetes::config":
        kubernetes_version => "1.10.2",
        container_runtime => "docker",
        manage_etcd => true,
        etcd_version => "3.1.12",
        etcd_ca_key => "foo",
        etcd_ca_crt => "foo", 
        etcdclient_key => "foo",
        etcdclient_crt => "foo",
        api_server_count => 3,
        kubernetes_ca_crt => "foo",
        kubernetes_ca_key => "foo",
        discovery_token_hash => "foo",
        sa_pub => "foo",
        sa_key => "foo",
        kube_api_advertise_address => "foo",
        cni_pod_cidr => "10.0.0.0/24",
        etcdserver_crt => "foo", 
        etcdserver_key => "foo", 
        etcdpeer_crt => "foo", 
        etcdpeer_key => "foo", 
        etcd_peers => ["foo"], 
        etcd_ip => "foo", 
        etcd_initial_cluster => "foo",  
        token => "foo",     
        apiserver_cert_extra_sans => ["foo"],
        apiserver_extra_arguments => ["foo"],
        service_cidr => "10.96.0.0/12",
        node_label => "foo",
        cloud_provider => ":undef",
        cloud_config => ":undef",        
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
        {
            'container_runtime' => 'docker',
            'controller' => true,
            'cloud_provider' => ':undef',
            'manage_docker' => false,
            'manage_etcd' => true,
        }
    end
    it { should_not contain_service('docker')}
    it { should contain_service('etcd')}
  end
end
