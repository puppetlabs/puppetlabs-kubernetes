# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'json'
require 'pry'

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
end
