# frozen_string_literal: true

require 'spec_helper'

describe 'kubernetes::kubeadm_init', type: :define do
  let(:pre_condition) { 'include kubernetes' }
  let(:title) { 'kubeadm init' }
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
      }
    }
  end

  context 'with apiserver_advertise_address => 10.0.0.1' do
    let(:params) do
      {
        'config' => '/etc/kubernetes/config.yaml',
        'node_name' => 'kube-control-plane',
        'path' => ['/bin', '/usr/bin', '/sbin'],
        'env' => ['KUBECONFIG=/etc/kubernetes/admin.conf']
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('kubeadm init').with_command("kubeadm init --config '/etc/kubernetes/config.yaml'") }
    it { is_expected.to contain_kubernetes__wait_for_default_sa('default') }
  end

  context 'with dry_run => true' do
    let(:params) do
      {
        'config' => '/etc/kubernetes/config.yaml',
        'node_name' => 'kube-control-plane',
        'path' => ['/bin', '/usr/bin', '/sbin'],
        'dry_run' => true,
        'env' => ['KUBECONFIG=/etc/kubernetes/admin.conf']
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('kubeadm init').with_command("kubeadm init --config '/etc/kubernetes/config.yaml' --dry-run") }
    it { is_expected.to contain_kubernetes__wait_for_default_sa('default') }
  end

  context 'with ignore_preflight => [foo, bar]' do
    let(:params) do
      {
        'config' => '/etc/kubernetes/config.yaml',
        'node_name' => 'kube-control-plane',
        'path' => ['/bin', '/usr/bin', '/sbin'],
        'ignore_preflight_errors' => ['foo', 'bar'],
        'env' => ['KUBECONFIG=/etc/kubernetes/admin.conf']
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('kubeadm init').with_command("kubeadm init --config '/etc/kubernetes/config.yaml' --ignore-preflight-errors='foo,bar'") }
    it { is_expected.to contain_kubernetes__wait_for_default_sa('default') }
  end
end
