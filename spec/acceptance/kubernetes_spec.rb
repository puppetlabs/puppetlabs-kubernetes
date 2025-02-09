# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'the Kubernetes module' do
  context 'clean up before each test' do
    describe 'kubernetes class', :integration do
      context 'it should install the module and run' do
        before(:all) { change_target_host('controller') }
        after(:all) { reset_target_host }

        # fetch_ip_hostname_by_role returns an array of 3 elements [hostname, ipaddress, internal_ipaddress]
        int_ipaddr1 = fetch_ip_hostname_by_role('controller')[2]

        pp = <<-MANIFEST
        case $facts['os']['family'] {
          /^(RedHat|CentOS)$/:  {
            class {'kubernetes':
              kubernetes_version => '1.28.15',
              kubernetes_package_version => '1.28.15',
              kubernetes_yum_baseurl => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/',
              kubernetes_yum_gpgkey => 'https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key',
              controller_address => "#{int_ipaddr1}:6443",
              container_runtime => 'docker',
              manage_docker => false,
              controller => true,
              schedule_on_controller => true,
              environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
              ignore_preflight_errors => ['NumCPU','ExternalEtcdVersion'],
              cgroup_driver => 'systemd',
              service_cidr => '10.138.0.0/12',
            }
          }
          /^(Debian|Ubuntu)$/: {
            class {'kubernetes':
              kubernetes_version => '1.28.15',
              kubernetes_package_version => '1.28.15-1.1',
              kubernetes_apt_location => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/',
              kubernetes_apt_repos => ' ',
              kubernetes_apt_release => ' /',
              kubernetes_key_source => 'https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key',
              controller => true,
              schedule_on_controller => true,
              environment  => ['HOME=/root', 'KUBECONFIG=/etc/kubernetes/admin.conf'],
              ignore_preflight_errors => ['NumCPU','ExternalEtcdVersion'],
            }
          }
          default:  {
            class {'kubernetes': } # any other OS are not supported
        }
      }
        MANIFEST

        it 'runs' do
          apply_manifest(pp)
        end

        it 'installs kubectl' do
          run_shell('kubectl')
        end

        it 'installs kube-dns' do
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get deploy --namespace kube-system coredns')
        end
      end

      context 'application deployment' do
        before(:all) { change_target_host('controller') }
        after(:all) { reset_target_host }

        int_ipaddr1 = fetch_ip_hostname_by_role('controller')[2]

        it 'can deploy an application into a namespace and expose it' do
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl create -f /tmp/nginx.yml') do |r|
            expect(r.stdout).to match(%r{my-nginx created\nservice/my-nginx created\n})
          end
        end

        it 'can access the deployed service' do
          run_shell('sleep 60')
          shell_command = "curl --retry 10 --retry-delay 15 -s #{int_ipaddr1}"
          run_shell(shell_command) do |r|
            expect(r.stdout).to match(%r{Welcome to nginx!})
          end
        end

        it 'can delete a deployment' do
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl delete -f /tmp/nginx.yml') do |r|
            expect(r.stdout).to match(%r{deployment.apps "my-nginx" deleted\nservice "my-nginx" deleted})
          end
          run_shell('KUBECONFIG=/etc/kubernetes/admin.conf kubectl get deploy --all-namespaces | grep nginx', expect_failures: true)
        end
      end
    end
  end
end
