# frozen_string_literal: true

require 'spec_helper'
describe 'kubernetes' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge({
                         ec2_metadata: {
                           hostname: 'ip-10-10-10-1.ec2.internal'
                         }
                       })
      end

      it { is_expected.to compile }

      context 'with controller => true and worker => true' do
        let(:params) do
          {
            controller: true,
            worker: true
          }
        end

        it { is_expected.to raise_error(%r{A node can not be both a controller and a node}) }
      end

      context 'with controller => true' do
        let(:params) do
          {
            controller: true
          }
        end

        it { is_expected.to contain_class('kubernetes') }
        it { is_expected.to contain_class('kubernetes::repos') }
        it { is_expected.to contain_class('kubernetes::packages') }
        it { is_expected.to contain_class('kubernetes::config::kubeadm') }
        it { is_expected.to contain_class('kubernetes::service') }
        it { is_expected.to contain_class('kubernetes::cluster_roles') }
        it { is_expected.to contain_class('kubernetes::kube_addons') }
      end

      context 'with worker => true and version => 1.10.2' do
        let(:params) do
          {
            worker: true
          }
        end

        it { is_expected.to contain_class('kubernetes') }
        it { is_expected.to contain_class('kubernetes::repos') }
        it { is_expected.to contain_class('kubernetes::packages') }
        it { is_expected.not_to contain_class('kubernetes::config::kubeadm') }
        it { is_expected.not_to contain_class('kubernetes::config::worker') }
        it { is_expected.to contain_class('kubernetes::service') }
      end

      context 'with worker => true and version => 1.12.2' do
        let(:params) do
          {
            worker: true,
            kubernetes_version: '1.12.2'
          }
        end

        it { is_expected.not_to contain_class('kubernetes::config::kubeadm') }
        it { is_expected.to contain_class('kubernetes::config::worker') }
      end

      context 'with node_label => foo and cloud_provider => undef' do
        let(:params) do
          {
            worker: true,
            node_label: 'foo',
            cloud_provider: :undef
          }
        end

        it { is_expected.not_to contain_notify('aws_node_name') }
      end

      context 'with node_label => foo and cloud_provider => aws' do
        let(:params) do
          {
            worker: true,
            node_label: 'foo',
            cloud_provider: 'aws'
          }
        end

        it { is_expected.to contain_notify('aws_name_override') }
      end

      context 'with node_label => undef and cloud_provider => aws' do
        let(:params) do
          {
            worker: true,
            node_label: :undef,
            cloud_provider: 'aws'
          }
        end

        it { is_expected.not_to contain_notify('aws_name_override') }
      end

      context 'with invalid node_label should not allow code injection' do
        let(:params) do
          {
            worker: true,
            node_label: 'hostname;rm -rf /'
          }
        end

        it { is_expected.to raise_error(%r{Evaluation Error: Error while evaluating}) }
      end
    end
  end
end
