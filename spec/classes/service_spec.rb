require 'spec_helper'
describe 'kubernetes::service', :type => :class do
  let(:facts) do
    {
      :kernel           => 'Linux',
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
        cloud_provider => "",
        cloud_config => "",
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'cri_containerd',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => true,
        'manage_etcd' => true,
      }
    end
   it { should contain_file('/etc/systemd/system/kubelet.service.d')}
   it { should contain_file('/etc/systemd/system/kubelet.service.d/0-containerd.conf')}
   it { should contain_file('/etc/systemd/system/containerd.service')}
   it { is_expected.to_not contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf')}
   it { should contain_exec('kubernetes-systemd-reload')}
   it { should contain_service('containerd')}
   it { should contain_service('etcd')}
   it { should contain_service('kubelet')}

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
        cloud_provider => "",
        cloud_config => "",
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'docker',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => true,
        'manage_etcd' => false,
      }
    end
    it { should contain_service('docker')}
    it { should_not contain_service('etcd')}
    it { should contain_service('kubelet')}

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
        cloud_provider => "",
        cloud_config => "",
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
        {
            'kubernetes_version' => '1.10.2',
            'container_runtime' => 'docker',
            'controller' => true,
            'cloud_provider' => '',
            'cloud_config' => '',
            'manage_docker' => false,
            'manage_etcd' => true,
        }
    end
    it { should_not contain_service('docker')}
    it { should contain_service('etcd')}
    it { should contain_service('kubelet')}
  end

  context 'with version => 1.10 and cloud_provider => aws and cloud_config => undef' do
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
        cloud_provider => "aws",
        cloud_config => "",
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
        {
            'kubernetes_version' => '1.10.2',
            'container_runtime' => 'docker',
            'controller' => true,
            'manage_docker' => true,
            'manage_etcd' => true,
            'cloud_provider' => 'aws',
            'cloud_config' => '',
        }
    end
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
      .with_content(/--cloud-provider=aws/)
    }
    it { is_expected.to_not contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
      .with_content(/--cloud-config=/)
    }
  end

  context 'with version => 1.10 and cloud_provider => openstack and cloud_config => /etc/kubernetes/cloud.conf' do
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
        cloud_provider => "openstack",
        cloud_config => "/etc/kubernetes/cloud.conf",
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
        {
            'kubernetes_version' => '1.10.2',
            'container_runtime' => 'docker',
            'controller' => true,
            'manage_docker' => true,
            'manage_etcd' => true,
            'cloud_provider' => 'openstack',
            'cloud_config' => '/etc/kubernetes/cloud.conf',
        }
    end
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
      .with_content(/--cloud-provider=openstack/)
    }
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
      .with_content(%r|--cloud-config=/etc/kubernetes/cloud.conf|)
    }
  end

  context 'with version => 1.12 and cloud_provider => aws' do
    let(:pre_condition) { 'class {"kubernetes::config":
        kubernetes_version => "1.12.3",
        container_runtime => "docker",
        manage_etcd => true,
        etcd_version => "3.3.10",
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
        cloud_provider => "aws",
        cloud_config => "",
        kubeadm_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_config => {"foo" => ["bar", "baz"]},
        kubelet_extra_arguments => ["foo"],
        image_repository => "k8s.gcr.io",
      }' }
    let(:params) do
        {
            'kubernetes_version' => '1.12.3',
            'container_runtime' => 'docker',
            'controller' => true,
            'manage_docker' => true,
            'manage_etcd' => true,
            'cloud_provider' => 'aws',
            'cloud_config' => '',
        }
    end
    it { is_expected.to_not contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf')}
  end
end
