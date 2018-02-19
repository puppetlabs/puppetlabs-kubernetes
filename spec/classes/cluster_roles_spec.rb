require 'spec_helper'
describe 'kubernetes::cluster_roles', :type => :class do
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

	  let(:params) { { 'bootstrap_controller' => true, 'kubernetes_version' => '1.7.3' } }

      it { should contain_exec('Create kube bootstrap token') }
      it { should contain_exec('Create kube proxy cluster bindings') }
  end
end
