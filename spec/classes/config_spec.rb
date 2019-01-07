require 'spec_helper'
describe 'kubernetes::config', :type => :class do
  let(:pre_condition) { 'include kubernetes' }
  let(:facts) do {
    :kernel => 'Linux',
    :networking => {
      :hostname => 'foo',
    },
    :os => {
      :family => "Debian",
      :name => 'Ubuntu',
      :release => {
        :full => '16.04',
      },
      :distro => {
        :codename => "xenial",
      },
    },
    :networking => {
      :hostname => 'foo',
    },
    :ec2_metadata => {
      :hostname => 'ip-10-10-10-1.ec2.internal',
    },
  } end

  context 'with manage_etcd => true' do
    let(:pre_condition) { 'include kubernetes' }
    let(:params) do 
      {
        'manage_etcd' => true,
        'kubeadm_extra_config' => {'foo' => ['bar', 'baz']},
        'kubelet_extra_config' => {'baz' => ['bar', 'foo']},
        'kubelet_extra_arguments' => ['foo'],
      }
    end

    kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/pki/etcd']
    etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
    pki = ['ca.crt', 'ca.key','sa.pub','sa.key']

    for d in kube_dirs do
    it { should contain_file("#{d}") }
    end

    for f in etcd do
    it { should contain_file("/etc/kubernetes/pki/etcd/#{f}") }
    end

    for cert in pki do
    it { should contain_file("/etc/kubernetes/pki/#{cert}") }
    end


    it { should contain_file('/etc/systemd/system/etcd.service') }
    it { should contain_file('/etc/kubernetes/config.yaml') }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/foo:\n- bar\n- baz/) }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/kubeletConfiguration:\n  baseConfig:\n    baz:\n    - bar\n    - foo/) }
  end

  context 'with manage_etcd => false' do
    let(:params) do 
        {
        'manage_etcd' => false,
        'kubeadm_extra_config' => {'foo' => ['bar', 'baz']},
        'kubelet_extra_config' => {'baz' => ['bar', 'foo']},
        'kubelet_extra_arguments' => ['foo'],
        }
    end

    kube_dirs = ['/etc/kubernetes/', '/etc/kubernetes/manifests', '/etc/kubernetes/pki', '/etc/kubernetes/pki/etcd']
    etcd = ['ca.crt', 'ca.key', 'client.crt', 'client.key','peer.crt', 'peer.key', 'server.crt', 'server.key']
    pki = ['ca.crt', 'ca.key','sa.pub','sa.key']

    for d in kube_dirs do
    it { should contain_file("#{d}") }
    end

    for f in etcd do
    it { should_not contain_file("/etc/kubernetes/pki/etcd/#{f}") }
    end

    for cert in pki do
    it { should contain_file("/etc/kubernetes/pki/#{cert}") }
    end


    it { should_not contain_file('/etc/systemd/system/etcd.service') }
    it { should contain_file('/etc/kubernetes/config.yaml') }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/foo:\n- bar\n- baz/) }
    it { should contain_file('/etc/kubernetes/config.yaml').with_content(/kubeletConfiguration:\n  baseConfig:\n    baz:\n    - bar\n    - foo/) }
  end

  context 'with version = 1.12 and cloud_provider => aws and cloud_config => undef' do
    let(:params) do
        {
        'kubernetes_version' => '1.12.3',
        'node_name' => 'foo',
        'cloud_provider' => 'aws',
        'cloud_config' => :undef,
        'kubelet_extra_arguments' => ['foo: bar'],
        }
    end

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') \
       .with_content(/nodeRegistration:\n  name: foo\n  kubeletExtraArgs:\n    foo: bar\n    cloud-provider: aws\n/)
    }
    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') \
       .without_content(%r{apiServerExtraVolumes:\n  - name: cloud\n})
    }
  end

  context 'with version = 1.12 and cloud_provider => aws and cloud_config => /etc/kubernetes/cloud.conf' do
    let(:params) do
        {
        'kubernetes_version' => '1.12.3',
        'node_name' => 'foo',
        'cloud_provider' => 'aws',
        'cloud_config' => '/etc/kubernetes/cloud.conf',
        'kubelet_extra_arguments' => ['foo: bar'],
        }
    end

    it { is_expected.to contain_file('/etc/kubernetes/config.yaml') \
       .with_content(%r{apiServerExtraVolumes:\n  - name: cloud\n})
    }
  end
end
