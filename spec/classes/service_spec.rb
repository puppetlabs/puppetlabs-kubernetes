# frozen_string_literal: true

require 'spec_helper'
describe 'kubernetes::service', type: :class do
  let(:pre_condition) { 'include kubernetes; include kubernetes::config::kubeadm' }
  let(:facts) do
    {
      kernel: 'Linux',
      os: {
        family: 'Debian',
        name: 'Ubuntu',
        release: {
          full: '16.04'
        },
        distro: {
          codename: 'xenial'
        }
      },
      ec2_metadata: {
        hostname: 'ip-10-10-10-1.ec2.internal'
      }
    }
  end

  context 'with controller => true and container_runtime => cri_containerd and manage_etcd => true' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'cri_containerd',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => true,
        'manage_etcd' => true
      }
    end

    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d') }
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/0-containerd.conf') }
    it { is_expected.to contain_file('/etc/systemd/system/containerd.service') }
    it { is_expected.not_to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') }
    it { is_expected.to contain_exec('kubernetes-systemd-reload') }
    it { is_expected.to contain_service('containerd') }
    it { is_expected.to contain_service('etcd') }
    it { is_expected.to contain_service('kubelet') }
  end

  context 'with controller => true and container_runtime => docker and manage_docker => true and manage_etcd => false' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'docker',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => true,
        'manage_etcd' => false
      }
    end

    it { is_expected.to contain_service('docker') }
    it { is_expected.not_to contain_service('etcd') }
    it { is_expected.to contain_service('kubelet') }
  end

  context 'with controller => true and container_runtime => docker and manage_docker => false and manage_etcd => true' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'docker',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => false,
        'manage_etcd' => true,
        'etcd_install_method' => 'wget'
      }
    end

    it { is_expected.not_to contain_service('docker') }
    it { is_expected.to contain_service('etcd') }
    it { is_expected.to contain_service('kubelet') }
    it { is_expected.to contain_exec('systemctl-daemon-reload-etcd') }
  end

  context 'with os.family => RedHat' do
    let(:facts) do
      super().merge({ os: { family: 'RedHat' } })
    end

    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/11-cgroups.conf') }
  end

  context 'with version => 1.10 and cloud_provider => aws and cloud_config => undef' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'docker',
        'controller' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'cloud_provider' => 'aws',
        'cloud_config' => ''
      }
    end

    it {
      expect(subject).to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
        .with_content(%r{--cloud-provider=aws})
    }

    it {
      expect(subject).not_to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
        .with_content(%r{--cloud-config=})
    }
  end

  context 'with version => 1.10 and cloud_provider => openstack and cloud_config => /etc/kubernetes/cloud.conf' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'docker',
        'controller' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'cloud_provider' => 'openstack',
        'cloud_config' => '/etc/kubernetes/cloud.conf'
      }
    end

    it {
      expect(subject).to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
        .with_content(%r{--cloud-provider=openstack})
    }

    it {
      expect(subject).to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') \
        .with_content(%r{--cloud-config=/etc/kubernetes/cloud.conf})
    }
  end

  context 'with version => 1.12 and cloud_provider => aws' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'container_runtime' => 'docker',
        'controller' => true,
        'manage_docker' => true,
        'manage_etcd' => true,
        'cloud_provider' => 'aws',
        'cloud_config' => ''
      }
    end

    it { is_expected.not_to contain_file('/etc/systemd/system/kubelet.service.d/20-cloud.conf') }
  end

  context 'with container_runtime => cri_containerd and container_runtime_use_proxy => true' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'cri_containerd',
        'container_runtime_use_proxy' => true,
        'http_proxy' => 'foo',
        'https_proxy' => 'bar',
        'no_proxy' => 'baz',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => true,
        'manage_etcd' => true
      }
    end

    it { is_expected.to contain_file('/etc/systemd/system/containerd.service.d') }
    it { is_expected.to contain_file('/etc/systemd/system/containerd.service.d/http-proxy.conf').with_content(%r{\s*Environment="HTTP_PROXY=foo"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/containerd.service.d/http-proxy.conf').with_content(%r{\s*Environment="HTTPS_PROXY=bar"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/containerd.service.d/http-proxy.conf').with_content(%r{\s*Environment="NO_PROXY=baz"\s*}) }
    it { is_expected.not_to contain_file('/etc/systemd/system/docker.service.d/http-proxy.conf') }
  end

  context 'with kubelet_use_proxy => true' do
    let(:params) do
      {
        'kubernetes_version' => '1.10.2',
        'container_runtime' => 'cri_containerd',
        'kubelet_use_proxy' => true,
        'http_proxy' => 'foo',
        'https_proxy' => 'bar',
        'no_proxy' => 'baz',
        'controller' => true,
        'cloud_provider' => '',
        'cloud_config' => '',
        'manage_docker' => true,
        'manage_etcd' => true
      }
    end

    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d') }
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/http-proxy.conf').with_content(%r{\s*Environment="HTTP_PROXY=foo"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/http-proxy.conf').with_content(%r{\s*Environment="HTTPS_PROXY=bar"\s*}) }
    it { is_expected.to contain_file('/etc/systemd/system/kubelet.service.d/http-proxy.conf').with_content(%r{\s*Environment="NO_PROXY=baz"\s*}) }
  end
end
