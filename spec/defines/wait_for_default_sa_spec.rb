require 'spec_helper'

describe 'kubernetes::wait_for_default_sa', :type => :define do
  let(:pre_condition) { 'include kubernetes' }
  let(:title) { 'default' }
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

  context 'with namespace default and no options' do
    let(:params) do
      {
        'namespace' => 'default',
      }
    end
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('wait for default serviceaccount creation in default')
          .with_command('kubectl -n default get serviceaccount default -o name')}
  end

  context 'with namespace foo and path /bar' do
    let(:params) do
      {
        'namespace' => 'foo',
        'path'      => ['/bar'],
      }
    end
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('wait for default serviceaccount creation in foo')
          .with_command('kubectl -n foo get serviceaccount default -o name')
          .with_path(['/bar'])}
  end
end
