# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'json'

describe 'we are able to setup a controller and workers', :integration do
  context 'set up the controller' do
    before(:all) { change_target_host('controller') }
    after(:all) { reset_target_host }
    describe 'set up controller' do
      it 'sets up the controller' do
        run_shell('puppet agent --test', expect_failures: true) do |r|
          expect(r.exit_code.to_s).to match(/0|2/)
        end
      end
    end
  end
  context 'set up the controller' do
    before(:all) { change_target_host('controller1') }
    after(:all) { reset_target_host }
    describe 'set up controller' do
      it 'sets up the controller' do
        run_shell('puppet agent --test', expect_failures: true) do |r|
          expect(r.exit_code.to_s).to match(/0|2/)
        end
      end
    end
  end
  context 'set up the worker1' do
    before(:all) { change_target_host('worker1') }
    after(:all) { reset_target_host }
    describe 'set up worker' do
      it 'sets up the worker' do
        run_shell('puppet agent --test', expect_failures: true) do |r|
          expect(r.exit_code.to_s).to match(/0|2/)
        end
      end
    end
  end
  context 'set up the worker2' do
    before(:all) { change_target_host('worker2') }
    after(:all) { reset_target_host }
    describe 'set up worker' do
      it 'sets up the worker' do
        run_shell('puppet agent --test', expect_failures: true) do |r|
          expect(r.exit_code.to_s).to match(/0|2/)
        end
      end
    end
  end
  context 'set up the worker2' do
    before(:all) { change_target_host('worker3') }
    after(:all) { reset_target_host }
    describe 'set up worker' do
      it 'sets up the worker' do
        run_shell('puppet agent --test', expect_failures: true) do |r|
          expect(r.exit_code.to_s).to match(/0|2/)
        end
      end
    end
  end
  context 'verify the k8 nodes' do
    before(:all) { change_target_host('controller') }
    hostname1, ipaddr1, int_ipaddr1 =  fetch_ip_hostname_by_role('controller')
    hostname1, ipaddr1, int_ipaddr1 =  fetch_ip_hostname_by_role('controller1')
    hostname2, ipaddr2, int_ipaddr2 =  fetch_ip_hostname_by_role('worker1')
    hostname3, ipaddr3, int_ipaddr3 =  fetch_ip_hostname_by_role('worker2')
    hostname3, ipaddr3, int_ipaddr3 =  fetch_ip_hostname_by_role('worker3')

    after(:all) { reset_target_host }
    describe 'verify the k8 nodes' do
      it 'verify the k8 nodes' do
        run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes') do |r|
          expect(r.stdout).to match(/#{hostname1}   Ready    master/)
          expect(r.stdout).to match(/#{hostname2}   Ready/)
          expect(r.stdout).to match(/#{hostname3}   Ready/)
        end
      end
    end
  end
end
