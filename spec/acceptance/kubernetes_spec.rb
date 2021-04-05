require 'spec_helper_acceptance'

describe 'the Kubernetes module' do
  context 'clean up before each test' do
    before(:each) do
    end

    describe 'kubernetes class', :integration do

      context 'it should install the module and run' do
        before(:all) { change_target_host('controller') }
        after(:all) { reset_target_host }
        pp = <<-MANIFEST
        if $facts['os']['family'] == 'redhat'{
          class {'kubernetes':
                  kubernetes_version => '1.20.0',
                  kubernetes_package_version => '1.20.0',
                  controller_address => "$::ipaddress:6443",
                  container_runtime => 'docker',
                  manage_docker => false,
                  controller => true,
                  schedule_on_controller => true,
                  environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                  ignore_preflight_errors => ['NumCPU','ExternalEtcdVersion'],
                  cgroup_driver => 'cgroupfs',
                }
          }
        if $facts['os']['family'] == 'debian'{
          class {'kubernetes':
                  controller => true,
                  schedule_on_controller => true,
                  environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                  ignore_preflight_errors => ['NumCPU'],
                }
          }
    MANIFEST

        it 'should run' do
          apply_manifest(pp)
        end

        it 'should install kubectl' do
          run_shell('kubectl')
        end

        it 'should install kube-dns' do
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get deploy --namespace kube-system coredns')
        end
      end

      context 'application deployment' do
        before(:all) { change_target_host('controller') }
        after(:all) { reset_target_host }
        it 'can deploy an application into a namespace and expose it' do
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl create -f /tmp/nginx.yml') do |r|
            expect(r.stdout).to match(/my-nginx created\nservice\/my-nginx created\n/)
          end
        end

        it 'can access the deployed service' do
          run_shell('sleep 60')
          run_shell('curl --retry 10 --retry-delay 15 -s 10.96.188.5') do |r|
            expect(r.stdout).to match (/Welcome to nginx!/)
          end
        end

        it 'can delete a deployment' do
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl delete -f /tmp/nginx.yml') do |r|
            expect(r.stdout).to match(/deployment.apps "my-nginx" deleted\nservice "my-nginx" deleted/)
          end
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get deploy --all-namespaces | grep nginx', :expect_failures => true)
        end
      end
    end
  end
end
