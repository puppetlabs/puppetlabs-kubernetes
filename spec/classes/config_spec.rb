require 'spec_helper'
describe 'kubernetes::config', :type => :class do
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

    context 'with controller => true' do
    let(:params) do
     {
        'kubernetes_version' => '1.7.3',
        'container_runtime' => 'docker',
        'cni_cluster_cidr' => '10.0.0.0/24',
        'cni_node_cidr' => '10.0.1.0/24',
        'kube_dns_version' => '1.14.2',
        'controller' => true,
        'bootstrap_controller' => false,
        'bootstrap_controller_ip' => '127.0.0.1',
        'worker' => false,
        'node_name' => 'kube_host',
        'kube_api_advertise_address' => '127.0.0.1',
        'etcd_version' => '3.0.17',
        'etcd_ip' => '127.0.01',
        'etcd_initial_cluster' => 'foo',
        'bootstrap_token' => 'foo',
        'bootstrap_token_name' => 'foo',
        'bootstrap_token_description' => 'foo',
        'bootstrap_token_id' => 'foo',
        'bootstrap_token_secret' => 'foo',
        'bootstrap_token_usage_bootstrap_authentication' => 'foo',
        'bootstrap_token_usage_bootstrap_signing' => 'foo',
        'bootstrap_token_expiration' => 'foo',
        'certificate_authority_data' => 'foo',
        'client_certificate_data_controller' => 'foo',
        'client_certificate_data_controller_manager' => 'foo',
        'client_certificate_data_scheduler' => 'foo',
        'client_certificate_data_worker' => 'foo',
        'client_certificate_data_admin' => 'foo',
        'client_key_data_controller' => 'foo',
        'client_key_data_controller_manager' => 'foo',
        'client_key_data_scheduler' => 'foo',
        'client_key_data_worker' => 'foo',
        'client_key_data_admin' => 'foo',
        'apiserver_kubelet_client_crt' => 'foo',
        'apiserver_kubelet_client_key' => 'foo',
        'apiserver_crt' => 'foo',
        'apiserver_key' => 'foo',
        'apiserver_extra_arguments' => ['--some-extra-arg=foo'],
        'kubernetes_fqdn' => 'kube.foo.dev',
        'ca_crt' => 'foo',
        'ca_key' => 'foo',
        'front_proxy_ca_crt' => 'foo',
        'front_proxy_ca_key' => 'foo',
        'front_proxy_client_crt' => 'foo',
        'front_proxy_client_key' => 'foo',
        'sa_key' => 'foo',
        'sa_pub' => 'foo',
      }
      end

      kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/addons', '/etc/kubernetes/secrets/']
      kube_cni_dirs = [ '/etc/cni', '/etc/cni/net.d']
      kube_etc_files = ['admin.conf', 'controller-manager.conf', 'kubelet.conf', 'scheduler.conf']
      kube_manifest_files = ['etcd.yaml', 'kube-apiserver.yaml', 'kube-controller-manager.yaml', 'kube-scheduler.yaml', 'clusterRoleBinding.yaml']
      kube_addons_files = ['kube-dns-sa.yaml','kube-dns-deployment.yaml', 'kube-dns-service.yaml', 'kube-proxy-sa.yaml', 'kube-proxy-daemonset.yaml', 'kube-proxy.yaml']
      kube_pki_files = ['apiserver.crt', 'apiserver-kubelet-client.crt', 'ca.crt', 'front-proxy-ca.crt', 'front-proxy-client.crt', 'sa.key','apiserver.key',  'apiserver-kubelet-client.key', 'ca.key', 'front-proxy-ca.key', 'front-proxy-client.key', 'sa.pub']

      for d in kube_dirs do
        it { should contain_file("#{d}") }
      end

      for d in kube_cni_dirs do
        it { should contain_file("#{d}") }
      end

      for kube_etc_file in kube_etc_files do
        it { should contain_file("/etc/kubernetes/#{kube_etc_file}") }
      end

      for kube_manifest_file in kube_manifest_files do
        it { should contain_file("/etc/kubernetes/manifests/#{kube_manifest_file}") }
      end

      for file in kube_addons_files do
        it { should contain_file("/etc/kubernetes/addons/#{file}") }
      end

      for kube_pki_file in kube_pki_files do
        it { should contain_file("/etc/kubernetes/pki/#{kube_pki_file}") }
      end

      it { should contain_file('/etc/kubernetes/secrets/bootstraptoken.yaml') }
      it { should contain_file('/root/admin.conf') }
      it { should contain_file('/etc/profile.d/kubectl.sh') }

      # Check API server config
      it {
        should contain_file('/etc/kubernetes/manifests/kube-apiserver.yaml')
                   .with_content(/^\s*- --experimental-bootstrap-token-auth=true$/) # with kubernetes_version = 1.7.x
                   .with_content(/^\s*- --some-extra-arg=foo$/)
      }
    end

  context 'with worker => true' do
  let(:params) do
    {
      'kubernetes_version' => '1.7.3',
      'container_runtime' => 'docker',
      'cni_cluster_cidr' => '10.0.0.0/24',
      'cni_node_cidr' => '10.0.1.0/24',
      'kube_dns_version' => '1.14.2',
      'controller' => true,
      'bootstrap_controller' => false,
      'bootstrap_controller_ip' => '127.0.0.1',
      'worker' => false,
      'node_name' => 'kube_host',
      'kube_api_advertise_address' => '127.0.0.1',
      'etcd_version' => '3.0.17',
      'etcd_ip' => '127.0.01',
      'etcd_initial_cluster' => 'foo',
      'bootstrap_token' => 'foo',
      'bootstrap_token_name' => 'foo',
      'bootstrap_token_description' => 'foo',
      'bootstrap_token_id' => 'foo',
      'bootstrap_token_secret' => 'foo',
      'bootstrap_token_usage_bootstrap_authentication' => 'foo',
      'bootstrap_token_usage_bootstrap_signing' => 'foo',
      'bootstrap_token_expiration' => 'foo',
      'certificate_authority_data' => 'foo',
      'client_certificate_data_controller' => 'foo',
      'client_certificate_data_controller_manager' => 'foo',
      'client_certificate_data_scheduler' => 'foo',
      'client_certificate_data_worker' => 'foo',
      'client_certificate_data_admin' => 'foo',
      'client_key_data_controller' => 'foo',
      'client_key_data_controller_manager' => 'foo',
      'client_key_data_scheduler' => 'foo',
      'client_key_data_worker' => 'foo',
      'client_key_data_admin' => 'foo',
      'apiserver_kubelet_client_crt' => 'foo',
      'apiserver_kubelet_client_key' => 'foo',
      'apiserver_crt' => 'foo',
      'apiserver_key' => 'foo',
      'apiserver_extra_arguments' => ['--some-extra-arg=foo'],
      'kubernetes_fqdn' => 'kube.foo.dev',
      'ca_crt' => 'foo',
      'ca_key' => 'foo',
      'front_proxy_ca_crt' => 'foo',
      'front_proxy_ca_key' => 'foo',
      'front_proxy_client_crt' => 'foo',
      'front_proxy_client_key' => 'foo',
      'sa_key' => 'foo',
      'sa_pub' => 'foo',
    }
    end

    kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki']
    kube_cni_dirs = [ '/etc/cni', '/etc/cni/net.d']
    kube_etc_files = ['kubelet.conf']
    kube_pki_files = ['ca.crt']
    kube_addons_files = []
    kube_manifest_files = []

    for d in kube_dirs do
      it { should contain_file("#{d}") }
    end

    for d in kube_cni_dirs do
      it { should contain_file("#{d}") }
    end

    for kube_etc_file in kube_etc_files do
      it { should contain_file("/etc/kubernetes/#{kube_etc_file}") }
    end

    for kube_manifest_file in kube_manifest_files do
      it { should contain_file("/etc/kubernetes/manifests/#{kube_manifest_file}") }
    end

    for file in kube_addons_files do
      it { should contain_file("/etc/kubernetes/addons/#{file}") }
    end

    for kube_pki_file in kube_pki_files do
      it { should contain_file("/etc/kubernetes/pki/#{kube_pki_file}") }
    end
  end
end
