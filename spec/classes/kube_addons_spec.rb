# frozen_string_literal: true

require 'spec_helper'
describe 'kubernetes::kube_addons', type: :class do
  let(:pre_condition) { 'include kubernetes' }
  let(:facts) do
    {
      os: {
        family: 'Debian',
        name: 'Ubuntu',
        release: {
          full: '22.04'
        },
        distro: {
          codename: 'jammy'
        }
      }
    }
  end

  context 'with controller => true and schedule_on_controller => true' do
    let(:params) do
      {
        controller: true,
        cni_rbac_binding: 'foo',
        cni_network_provider: 'https://foo.test',
        install_dashboard: false,
        kubernetes_version: '1.25.4',
        schedule_on_controller: true,
        node_name: 'foo'
      }
    end

    it {
      expect(subject).to contain_exec('Install calico rbac bindings').with({
                                                                             command: ['kubectl', 'apply', '-f', 'foo'],
                                                                             onlyif: ['kubectl get nodes']
                                                                           })
    }

    it {
      expect(subject).to contain_exec('Install cni network provider').with({
                                                                             command: ['kubectl', 'apply', '-f', 'https://foo.test'],
                                                                             onlyif: ['kubectl get nodes']
                                                                           })
    }

    it { is_expected.to contain_exec('schedule on controller') }

    it { is_expected.not_to contain_exec('Install cni network (preinstall)') }
    it { is_expected.not_to contain_file('/etc/kubernetes/calico-installation.yaml') }
    it { is_expected.not_to contain_file_line('Configure calico ipPools.cidr') }
  end

  context 'CNI network provider' do
    ['flannel', 'weave', 'calico', 'cilium', 'calico-tigera'].each do |provider|
      context "with #{provider}" do
        let(:params) do
          {
            controller: true,
            cni_network_provider: "https://#{provider}.test",
            cni_network_preinstall: 'https://foo.test/tigera-operator',
            cni_provider: provider,
            install_dashboard: false,
            kubernetes_version: '1.25.4',
            node_name: 'foo'
          }
        end

        it { is_expected.to contain_class('kubernetes::kube_addons') }

        case provider
        when 'calico-tigera'
          it {
            expect(subject).to contain_exec('Install cni network (preinstall)').with({
                                                                                       command: ['kubectl', 'create', '-f', 'https://foo.test/tigera-operator'],
                                                                                       onlyif: 'kubectl get nodes'
                                                                                     })
          }

          it { is_expected.to contain_file('/etc/kubernetes/calico-installation.yaml') }
          it { is_expected.to contain_file_line('Configure calico ipPools.cidr') }
          it { is_expected.to contain_exec('Install cni network provider') }
        when 'flannel'
          it {
            expect(subject).to contain_exec('Install cni network provider').with(
              {
                onlyif: ['kubectl get nodes'],
                command: ['kubectl', 'create', '-f', "https://#{provider}.test"],
                unless: ['kubectl -n kube-flannel get daemonset | egrep "^kube-flannel"']
              },
            )
          }
        else
          it {
            expect(subject).to contain_exec('Install cni network provider').with({
                                                                                   onlyif: ['kubectl get nodes'],
                                                                                   command: ['kubectl', 'apply', '-f', "https://#{provider}.test"],
                                                                                   unless: ['kubectl -n kube-system get daemonset | egrep "(flannel|weave|calico-node|cilium)"']
                                                                                 })
          }

          it {
            expect(subject).not_to contain_exec('Install cni network (preinstall)').with({
                                                                                           onlyif: ['kubectl get nodes']
                                                                                         })
          }
        end
      end
    end
  end

  context 'with install_dashboard => false' do
    let(:params) do
      {
        controller: true,
        cni_rbac_binding: nil,
        cni_network_provider: 'https://foo.test',
        install_dashboard: false,
        kubernetes_version: '1.25.4',
        schedule_on_controller: false,
        node_name: 'foo'
      }
    end

    it { is_expected.not_to contain_exec('Install Kubernetes dashboard') }
  end

  context 'with install_dashboard => true' do
    let(:params) do
      {
        controller: true,
        cni_rbac_binding: nil,
        cni_network_provider: 'https://foo.test',
        install_dashboard: true,
        kubernetes_version: '1.25.4',
        dashboard_version: '1.10.1',
        schedule_on_controller: false,
        node_name: 'foo'
      }
    end

    it { is_expected.to contain_exec('Install Kubernetes dashboard').with_command(%r{dashboard/v1.10.1/src}) }
  end
end
