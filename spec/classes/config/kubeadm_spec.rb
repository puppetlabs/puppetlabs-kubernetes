require 'spec_helper'
describe 'kubernetes::config::kubeadm', :type => :class do
  let(:pre_condition) { 'include kubernetes' }
  let(:facts) do
    {
      :kernel => 'Linux',
      :networking => {
        :hostname => 'foo',
      },
      :os => {
        :family => 'Debian',
        :name => 'Ubuntu',
        :release => {
          :full => '16.04',
        },
        :distro => {
          :codename => 'xenial',
        },
      },
      :ec2_metadata => {
        :hostname => 'ip-10-10-10-1.ec2.internal',
      },
    }
  end

  context 'with manage_etcd => true' do
    let(:pre_condition) { 'include kubernetes' }
    let(:params) do
      {
        'manage_etcd' => true,
        'kubeadm_extra_config' => { 'foo' => ['bar', 'baz'] },
        'kubelet_extra_config' => { 'baz' => ['bar', 'foo'] },
        'kubelet_extra_arguments' => ['foo'],
      }
    end

    kube_dirs = ['/etc/kubernetes', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/pki/etcd']
    etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key', 'peer.crt', 'peer.key', 'server.crt', 'server.key']
    pki = ['ca.crt', 'ca.key', 'front-proxy-ca.crt', 'front-proxy-ca.key', 'sa.pub', 'sa.key']

    kube_dirs.each do |d|
      it { is_expected.to contain_file(d.to_s) }
    end

    etcd.each do |f|
      it { is_expected.to contain_file("/etc/kubernetes/pki/etcd/#{f}") }
    end

    pki.each do |cert|
      it { is_expected.to contain_file("/etc/kubernetes/pki/#{cert}") }
    end

    it { is_expected.to contain_file('/etc/systemd/system/etcd.service') }
    it { is_expected.not_to contain_file('/etc/default/etcd') }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{foo:\n- bar\n- baz}) }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{kubeletConfiguration:\n  baseConfig:\n    baz:\n    - bar\n    - foo}) }
  end

  context 'with manage_etcd => false' do
    let(:params) do
      {
        'manage_etcd' => false,
        'kubeadm_extra_config' => { 'foo' => ['bar', 'baz'] },
        'kubelet_extra_config' => { 'baz' => ['bar', 'foo'] },
        'kubelet_extra_arguments' => ['foo'],
      }
    end

    kube_dirs = ['/etc/kubernetes', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/pki/etcd']
    etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key', 'peer.crt', 'peer.key', 'server.crt', 'server.key']
    pki = ['ca.crt', 'ca.key', 'front-proxy-ca.crt', 'front-proxy-ca.key', 'sa.pub', 'sa.key']

    kube_dirs.each do |d|
      it { is_expected.to contain_file(d.to_s) }
    end

    etcd.each do |f|
      it { is_expected.not_to contain_file("/etc/kubernetes/pki/etcd/#{f}") }
    end

    pki.each do |cert|
      it { is_expected.to contain_file("/etc/kubernetes/pki/#{cert}") }
    end

    it { is_expected.not_to contain_file('/etc/systemd/system/etcd.service') }
    it { is_expected.not_to contain_file('/etc/default/etcd') }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{foo:\n- bar\n- baz}) }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{kubeletConfiguration:\n  baseConfig:\n    baz:\n    - bar\n    - foo}) }
  end

  context 'manage_etcd => true and etcd_install_method => package' do
    let(:params) do
      {
        'etcd_install_method' => 'package',
        'kubeadm_extra_config' => { 'foo' => ['bar', 'baz'] },
        'kubelet_extra_config' => { 'baz' => ['bar', 'foo'] },
        'kubelet_extra_arguments' => ['foo'],
        'manage_etcd' => true,
      }
    end

    it { is_expected.not_to contain_file('/etc/systemd/system/etcd.service') }
    it { is_expected.to contain_file('/etc/default/etcd') }
  end

  context 'with version = 1.12 and node_name => foo and cloud_provider => aws' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'node_name' => 'foo',
        'cloud_provider' => 'aws',
        'cloud_config' => :undef,
        'kubelet_extra_arguments' => ['foo: bar'],
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has node_name==foo in first YAML document (InitConfig)' do
      expect(config_yaml[0]['nodeRegistration']).to include('name' => params['node_name'])
    end
    it 'has cgroup-driver==cgroupfs in first YAML document (InitConfig) NodeRegistration' do
      expect(config_yaml[0]['nodeRegistration']['kubeletExtraArgs']).to include('cgroup-driver' => 'cgroupfs')
    end
    it 'has cloud-provider==aws in first YAML document (InitConfig) NodeRegistration' do
      expect(config_yaml[0]['nodeRegistration']['kubeletExtraArgs']).to include('cloud-provider' => params['cloud_provider'])
    end
    it 'does not have cloud-config in second YAML document (InitConfig) NodeRegistration' do
      expect(config_yaml[0]['nodeRegistration']['kubeletExtraArgs']).not_to include('cloud-config')
    end
  end

  context 'with version = 1.12 and cgroup_driver => systemd and cloud_provider => aws and cloud_config => /etc/kubernetes/cloud.conf' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'node_name' => 'foo',
        'cgroup_driver' => 'systemd',
        'cloud_provider' => 'aws',
        'cloud_config' => '/etc/kubernetes/cloud.conf',
        'kubelet_extra_arguments' => ['foo: bar'],
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it 'has API Server extra volumes in YAML document' do
      expect(config_yaml[1]).to include('apiServerExtraVolumes')
    end
    it 'has cgroup-driver==systemd in first YAML document (InitConfig) NodeRegistration' do
      expect(config_yaml[0]['nodeRegistration']['kubeletExtraArgs']).to include('cgroup-driver' => 'systemd')
    end
  end

  context 'with version = 1.12 and kubernetes_cluster_name => my_own_name' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'kubernetes_cluster_name' => 'my_own_name',
      }
    end

    it {
      is_expected.to contain_file('/etc/kubernetes/config.yaml') \
        .with_content(%r{clusterName: my_own_name\n})
    }
  end

  context 'with version = 1.13 and kubernetes_cluster_name => my_own_name' do
    let(:params) do
      {
        'kubernetes_version' => '1.13.0',
        'kubernetes_cluster_name' => 'my_own_name',
      }
    end

    it {
      is_expected.to contain_file('/etc/kubernetes/config.yaml') \
        .with_content(%r{clusterName: my_own_name\n})
    }
  end

  context 'with version = 1.14' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.1',
        'apiserver_extra_arguments' => ['foo', 'bar'],
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has foo in API server arguments' do
      expect(config_yaml[1]['apiServer']['extraArgs']).to include('foo')
    end
    it 'has bar in API server arguments' do
      expect(config_yaml[1]['apiServer']['extraArgs']).to include('bar')
    end
  end

  context 'with version = 1.14' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.1',
        'controllermanager_extra_arguments' => ['foo', 'bar'],
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has foo in controller manager arguments' do
      expect(config_yaml[1]['controllerManager']['extraArgs']).to include('foo')
    end
    it 'has bar in controller manager  arguments' do
      expect(config_yaml[1]['controllerManager']['extraArgs']).to include('bar')
    end
  end

  context 'with version = 1.14' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.1',
        'apiserver_extra_volumes' => {
          'foo' => {
            'hostPath'  => '/mnt',
            'mountPath' => '/data',
            'readOnly' => false,
            'pathType' => 'Directory',
          },
        },
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has hostPath: /mnt in API server extra volumes' do
      expect(config_yaml[1]['apiServer']['extraVolumes']).to include('name' => 'foo', 'hostPath' => '/mnt', 'mountPath' => '/data', 'readOnly' => false, 'pathType' => 'Directory')
    end
  end

  context 'with version = 1.14' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.1',
        'controllermanager_extra_volumes' => {
          'foo' => {
            'hostPath'  => '/mnt',
            'mountPath' => '/data',
            'readOnly' => false,
            'pathType' => 'Directory',
          },
        },
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has hostPath: /mnt in controller manager extra volumes' do
      expect(config_yaml[1]['controllerManager']['extraVolumes']).to include('name' => 'foo', 'hostPath' => '/mnt', 'mountPath' => '/data', 'readOnly' => false, 'pathType' => 'Directory')
    end
  end

  context 'with version = 1.14' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.1',
        'controller_address' => 'foo',
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has foo in controlPlaneEndpoint' do
      expect(config_yaml[1]['controlPlaneEndpoint']).to include('foo')
    end
  end

  context 'with version = 1.14' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.2',
        'proxy_mode' => 'ipvs',
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has ipvs in mode:' do
      expect(config_yaml[2]['mode']).to include('ipvs')
    end
  end

  context 'with metrics_bind_address = 0.0.0.0 with version 1.14.2' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.2',
        'metrics_bind_address' => '0.0.0.0',
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has 0.0.0.0 in metrics_bind_address:' do
      expect(config_yaml[2]['metricsBindAddress']).to include('0.0.0.0')
    end
  end

  context 'with metrics_bind_address = 0.0.0.0 with version 1.16.3' do
    let(:params) do
      {
        'kubernetes_version' => '1.16.3',
        'metrics_bind_address' => '0.0.0.0',
      }
    end

    let(:config_yaml) { YAML.load_stream(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') }
    it 'has 0.0.0.0 in metrics_bind_address:' do
      expect(config_yaml[2]['metricsBindAddress']).to include('0.0.0.0')
    end
  end

  context 'with metrics_bind_address = invalid' do
    let(:params) do
      {
        'kubernetes_version' => '1.14.2',
        'metrics_bind_address' => 'invalid',
      }
    end

    it { is_expected.to compile.and_raise_error(%r{metrics_bind_address}) }
  end
end
