require 'spec_helper'

describe 'kubernetes::kubeadm_init', :type => :define do
  let(:title) { 'kubeadm init' }
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
    }
  end

  context 'with apiserver_advertise_address => 10.0.0.1' do
  let(:params) { {
                  'apiserver_advertise_address' => '10.0.0.1',
                  'node_name' => 'kube-master',
                  'path' => [ '/bin','/usr/bin','/sbin'],
                  'env' => [ 'KUBECONFIG=/etc/kubernetes/admin.conf'],

               } }
   it { should compile.with_all_deps }  
   it { should contain_exec('kubeadm init').with_command("kubeadm init --apiserver-advertise-address '10.0.0.1' --node-name 'kube-master'")}
  end
end
