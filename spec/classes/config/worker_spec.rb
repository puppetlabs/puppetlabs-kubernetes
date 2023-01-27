# frozen_string_literal: true

require 'spec_helper'
describe 'kubernetes::config::worker', :type => :class do
  let(:pre_condition) { 'include kubernetes' }
  let(:facts) do
    {
      kernel: 'Linux',
      networking: {
        hostname: 'foo',
      },
      os: {
        family: 'Debian',
        name: 'Ubuntu',
        release: {
          full: '16.04',
        },
        distro: {
          codename: 'xenial',
        },
      },
      ec2_metadata: {
        hostname: 'ip-10-10-10-1.ec2.internal',
      },
    }
  end

  context 'with default params' do
    let(:config_yaml) { YAML.safe_load(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').that_requires('File[/etc/kubernetes]') }
  end

  context 'with version => 1.12.3 and node_name => foo and kubelet_extra_args => foo: bar' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'node_name' => 'foo',
        'kubelet_extra_arguments' => ['foo: bar'],
      }
    end

    let(:config_yaml) { YAML.safe_load(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{apiVersion: kubeadm.k8s.io/v1alpha3\n}) }
    it 'has arg foo in first YAML document (JoinConfig) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['kubeletExtraArgs']).to include('foo')
    end
    it 'has name==foo in first YAML document (JoinConfig) NodeRegistration' do
      expect(config_yaml['nodeRegistration']).to include('name' => params['node_name'])
    end
    it 'does not have cloud-provider in first YAML document (JoinConfig) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['kubeletExtraArgs']).not_to include('cloud-provider')
    end
  end

  context 'with version => 1.12.3 and cloud_provider => aws' do
    let(:params) do
      {
        'kubernetes_version' => '1.12.3',
        'cloud_provider' => 'aws',
      }
    end

    let(:config_yaml) { YAML.safe_load(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml').with_content(%r{apiVersion: kubeadm.k8s.io/v1alpha3\n}) }
    it 'does not have arg foo in first YAML document (JoinConfig) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['kubeletExtraArgs']).not_to include('foo')
    end
    it 'has cloud-provider==aws in first YAML document (JoinConfig) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['kubeletExtraArgs']).to include('cloud-provider' => 'aws')
    end
  end

  context 'with version => 1.20.0 and node_extra_taints => [{key => key1, value => NewNode, effect => NoSchedule, operator => Equal}' do
    let(:params) do
      {
        'kubernetes_version' => '1.20.0',
        'node_extra_taints' => [
          {
            'key' => 'key1',
            'value' => 'NewNode',
            'effect' => 'NoSchedule',
            'operator' => 'Equal',
          },
          {
            'key' => 'key2',
            'value' => 'NewNode',
            'effect' => 'NoSchedule',
            'operator' => 'Equal',
          },
        ],
      }
    end

    let(:config_yaml) { YAML.safe_load(catalogue.resource('file', '/etc/kubernetes/config.yaml').send(:parameters)[:content]) }

    it 'has arg key1 in first YAML document (taints) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['taints'][0]['key']).to include('key1')
    end
    it 'has arg key2 in first YAML document (taints) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['taints'][1]['key']).to include('key2')
    end
    it 'has arg effect in first YAML document (taints) NodeRegistration' do
      expect(config_yaml['nodeRegistration']['taints'][0]['effect']).to include('NoSchedule')
    end
  end
end
