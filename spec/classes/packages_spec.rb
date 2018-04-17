require 'spec_helper'
describe 'kubernetes::packages', :type => :class do
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
    cni_node_cidr => true,
    cluster_service_cidr => "10.0.0.0/24",
    kube_dns_ip => "10.0.0.10",
    kube_dns_version => "1.14.2",
    kube_proxy_version => "1.6.6",
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
    apiserver_extra_volumes => [],
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

  let(:params) do
    {
      'kubernetes_package_version' => '1.9.2-00',
      'container_runtime' => 'docker',
      'docker_package_name' => 'docker-engine',
      'docker_package_version' => '1.12.0-0~xenial',
      'package_pin' => true,
      'cni_package_name' => 'kubernetes-cni',
      'cni_version' => '0.6.0-00',
    }
  end

  context 'with defaults for params and osfamily => Debian' do
    it { should contain_file('/etc/apt/preferences.d/docker-engine.pref').with('content' => %r{Package: docker-engine}) }
    it { should contain_file('/etc/apt/preferences.d/docker-engine.pref').with('content' => %r{Pin: version 1.12.0-0~xenial}) }
    it { should contain_file('/etc/apt/preferences.d/kube.pref').with('content' => %r{Package: kubelet kubectl}) }
    it { should contain_file('/etc/apt/preferences.d/kube.pref').with('content' => %r{Pin: version 1.9.2-00}) }
    it { should contain_file('/etc/apt/preferences.d/kubernetes-cni.pref').with('content' => %r{Package: kubernetes-cni}) }
    it { should contain_file('/etc/apt/preferences.d/kubernetes-cni.pref').with('content' => %r{Pin: version 0.6.0-00}) }

    it { should contain_package('docker-engine').with_ensure('1.12.0-0~xenial')}
    it { should contain_package('kubelet').with_ensure('1.9.2-00')}
    it { should contain_package('kubectl').with_ensure('1.9.2-00')}
    it { should contain_package('kubernetes-cni').with_ensure('0.6.0-00')}
  end
end
