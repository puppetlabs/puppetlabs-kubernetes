require 'spec_helper_acceptance'

describe 'the Kubernetes module' do
  context 'clean up before each test' do
    before(:each) do
    end

    describe 'kubernetes class' do

      context 'it should install the module and run' do

        pp = <<-MANIFEST
        if $::osfamily == 'RedHat'{
          class {'kubernetes':
                  container_runtime => 'docker',
                  manage_docker => false,
                  controller => true,
                  schedule_on_controller => true,
                  environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                  ignore_preflight_errors => ['NumCPU'],
                  cgroup_driver => 'cgroupfs'
                }
          }
        if $::osfamily == 'Debian'{
          class {'kubernetes':
                  controller => true,
                  schedule_on_controller => true,
                  environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
                  ignore_preflight_errors => ['NumCPU'],
                }
          }
    MANIFEST
        
        it 'should run' do
          apply_manifest(pp, :catch_failures => true)
        end

        it 'should install kubectl' do
          shell('kubectl', :acceptable_exit_codes => [0])
        end

        it 'should install kube-dns' do
          shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get deploy --namespace kube-system coredns', :acceptable_exit_codes => [0])
        end
      end

      context 'application deployment' do

        it 'can deploy an application into a namespace and expose it' do
          shell('sleep 180')
          shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl create -f /tmp/nginx.yml', :acceptable_exit_codes => [0]) do |r|
            expect(r.stdout).to match(/namespace\/nginx created\ndeployment.apps\/my-nginx created\nservice\/my-nginx created\n/)
          end
        end

        it 'can access the deployed service' do
          shell('sleep 60')
          shell('curl -s 10.96.188.5', :acceptable_exit_codes => [0]) do |r|
            expect(r.stdout).to match (/Welcome to nginx!/)
          end
        end

        it 'can delete a deployment' do
          shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl delete -f /tmp/nginx.yml', :acceptable_exit_codes => [0]) do |r|
            expect(r.stdout).to match(/namespace "nginx" deleted\ndeployment.apps "my-nginx" deleted\nservice "my-nginx" deleted/)
          end
          shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get deploy --all-namespaces | grep nginx', :acceptable_exit_codes => [1])
        end
      end
    end
  end
end
