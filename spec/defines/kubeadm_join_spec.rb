require 'spec_helper'

describe 'kubernetes::kubeadm_join', :type => :define do
  let(:title) { 'kubeadm join' }
  let(:facts) do
    {
      :lsbdistcodename  => 'xenial',
      :osfamily         => 'Debian',
      :operatingsystem  => 'Ubuntu',
      :os               => {
        :name    => 'Ubuntu',
        :release => {
          :full => '16.04',
        },     
      },
    }
  end   

 context 'with controller_address => 10.0.0.1:6443' do
  let(:params) { {
                  'controller_address' => '10.0.0.1:6443',
                  'node_name' => 'kube-node',
                  'path' => [ '/bin','/usr/bin','/sbin'],
                  'env' => [ 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                  'token' => 'token',
                  'ca_cert_hash' => 'hash',
                  'node_label' => 'kube-node',
                  
               } }

      it { should compile.with_all_deps }
      it { should contain_exec('kubeadm join').with_command("kubeadm join '10.0.0.1:6443' --discovery-token-ca-cert-hash 'sha256:hash' --node-name 'kube-node' --token 'token'")}
  end
end