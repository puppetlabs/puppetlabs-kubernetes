require 'spec_helper'
describe 'kubernetes::kube_addons', :type => :class do
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

  context 'with bootstrap_controller => true' do
    let(:params) do {
      'bootstrap_controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'kubernetes_version' => '1.7.3',
      'controller' => true,
      'taint_master' => true
      }
    end

    it { should contain_exec('Install cni network provider') }
    it { should contain_exec('Create kube proxy service account') }
    it { should contain_exec('Create kube proxy ConfigMap') }
    it { should contain_exec('Create kube proxy daemonset') }
    it { should contain_exec('Create kube dns service account') }
    it { should contain_exec('Create kube dns service') }
    it { should contain_exec('Create kube dns deployment') }
    it { should contain_exec('Assign master role to controller') }
    it { should contain_exec('Checking for dns to be deployed') }
    it { should contain_exec('Taint master node') }
  end

  context 'with controller => true and taint_master => true' do
    let(:params) do {
      'bootstrap_controller' => false,
      'controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => false,
      'kubernetes_version' => '1.7.3',
      'taint_master' => true
      }
    end
    it { should contain_exec('Checking for dns to be deployed') }
    it { should contain_exec('Taint master node') }
  end

  context 'with install_dashboard => true' do
    let(:params) do {
      'bootstrap_controller' => true,
      'cni_network_provider' => 'https://foo.test',
      'install_dashboard' => true,
      'kubernetes_version' => '1.7.3',
      'controller' => true,
      'taint_master' => false
      }
    end

    it { should contain_exec('Install Kubernetes dashboard')}
  end
end
