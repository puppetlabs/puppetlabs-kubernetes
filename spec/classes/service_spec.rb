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
 let(:pre_condition) { 'class {"kubernetes::config":
    kubernetes_version => "1.7.3",
    container_runtime => "docker",
    cni_cluster_cidr => "10.0.0.0/24",
    cni_node_cidr => "10.0.1.0/24",
    kube_dns_version => "1.14.2",
    controller => true,
    bootstrap_controller => false,
    bootstrap_controller_ip => "127.0.0.1",
    worker => false,
    node_name => "kube_host",
    kube_api_advertise_address => "127.0.0.1",
    etcd_version => "3.0.17",
    etcd_ip => "127.0.01",
    etcd_initial_cluster => "foo",
    bootstrap_token => "foo",
    bootstrap_token_name => "foo",
    bootstrap_token_description => "foo",
    bootstrap_token_id => "foo",
    bootstrap_token_secret => "foo",
    bootstrap_token_usage_bootstrap_authentication => "foo",
    bootstrap_token_usage_bootstrap_signing => "foo",
    bootstrap_token_expiration => "foo",
    certificate_authority_data => "foo",
    client_certificate_data_controller => "foo",
    client_certificate_data_controller_manager => "foo",
    client_certificate_data_scheduler => "foo",
    client_certificate_data_worker => "foo",
    client_certificate_data_admin => "foo",
    client_key_data_controller => "foo",
    client_key_data_controller_manager => "foo",
    client_key_data_scheduler => "foo",
    client_key_data_worker => "foo",
    client_key_data_admin => "foo",
    apiserver_kubelet_client_crt => "foo",
    apiserver_kubelet_client_key => "foo",
    apiserver_crt => "foo",
    apiserver_key => "foo",
    apiserver_extra_arguments => ["--some-extra-arg=foo"],
    kubernetes_fqdn => "kube.foo.dev",
    ca_crt => "foo",
    ca_key => "foo",
    front_proxy_ca_crt => "foo",
    front_proxy_ca_key => "foo",
    front_proxy_client_crt => "foo",
    front_proxy_client_key => "foo",
    sa_key => "foo",
    sa_pub => "foo" }
    ' }
  context 'with defaults for all params' do
    let(:params) do
      {
        'container_runtime' => 'docker',
	      'controller' => false,
        'bootstrap_controller' => false,
        'etcd_ip' => '127.0.0.1',
      }
    end

   it { should contain_service('docker') }
   it { should contain_file('/etc/systemd/system/kubelet.service.d') }
   it { should contain_file('/etc/systemd/system/kubelet.service.d/kubernetes.conf') }
   it { should contain_exec('Reload systemd') }
   it { should contain_service('kubelet') }
  end

  context 'with bootstrap_controller => yes' do
    let(:params) do
      {
        'container_runtime' => 'docker',
	      'bootstrap_controller' => true,
        'controller' => true,
        'etcd_ip' => '127.0.0.1',
      }
    end

    it { should contain_exec('Checking for the Kubernets cluster to be ready')}
  end
end
