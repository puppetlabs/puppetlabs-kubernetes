require 'spec_helper'
describe 'kubernetes::service', :type => :class do
  let(:pre_condition) { 'include kubernetes; include kubernetes::config::kubeadm' }
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
      :ec2_metadata     => {
        :hostname => 'ip-10-10-10-1.ec2.internal',
      },
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
    let(:params) do
        {
            'kubernetes_version' => '1.10.2',
            'container_runtime' => 'docker',
            'controller' => true,
            'cloud_provider' => '',
            'cloud_config' => '',
            'manage_docker' => false,
            'manage_etcd' => true,
            'etcd_install_method' => 'wget',
        }
    end
    it { should_not contain_service('docker')}
    it { should contain_service('etcd')}
    it { should contain_service('kubelet')}
    it { should contain_exec('systemctl-daemon-reload-etcd') }
  end

  context 'with os.family => RedHat' do
    let(:facts) do
      super().merge({ :os => { :family => 'RedHat' }})
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
