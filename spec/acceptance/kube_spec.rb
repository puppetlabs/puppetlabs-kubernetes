require 'spec_helper_acceptance'

describe 'the Kubernetes module' do
  context 'clean up before each test' do
    before(:each) do
    end


    describe 'kubernetes class' do
      context 'it should install the module and run' do
        let(:pp) {"
        class {'kubernetes':
          controller          => true,
          bootstrap_controller => true,
        }
        "}

        it 'should run' do
          apply_manifest(pp, :catch_failures => true)
        end

        it 'should install kubectl' do
          shell('kubectl', :acceptable_exit_codes => [0])
        end
      end
    end
  end
end