require 'spec_helper'

describe 'kubernetes::kubeadm_join', :type => :define do
  let(:pre_condition) { 'include kubernetes' }
  let(:title) { 'kubeadm join' }
  let(:facts) do
    {
      :kernel           => 'Linux',
      :os               => {
        :family  => "Debian",
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

  let(:params) do
    {
      'config' => '/etc/kubernetes/config.yaml',
      'controller_address' => '10.0.0.1:6443',
      'node_name' => 'kube-node',
      'path' => [ '/bin','/usr/bin','/sbin'],
      'env' => [ 'KUBECONFIG=/etc/kubernetes/admin.conf'],
      'discovery_token' => 'token',
      'token' => 'token',
      'tls_bootstrap_token' => 'token',
      'ca_cert_hash' => 'hash',
    }
  end

  context 'with kubernetes_version => 1.10.2 and controller_address => 10.0.0.1:6443' do
    let(:params) do
      super().merge({'kubernetes_version' => '1.10.2'})
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('kubeadm join').with_command("kubeadm join '10.0.0.1:6443' --discovery-token 'token' --discovery-token-ca-cert-hash 'sha256:hash' --node-name 'kube-node' --token 'token'")}
  end

  context 'with kubernetes_version => 1.12.3 and controller_address => 10.0.0.1:6443' do
    let(:params) do
      super().merge({:kubernetes_version => '1.12.3'})
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('kubeadm join').with_command("kubeadm join --config '/etc/kubernetes/config.yaml'")}
  end
end
