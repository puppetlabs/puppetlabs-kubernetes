# frozen_string_literal: true

require 'spec_helper'

describe 'kubernetes::wait_for_default_sa', type: :define do
  let(:pre_condition) { 'include kubernetes' }
  let(:title) { 'default' }
  let(:facts) do
    {
      kernel: 'Linux',
      os: {
        family: 'Debian',
        name: 'Ubuntu',
        release: {
          full: '16.04'
        },
        distro: {
          codename: 'xenial'
        }
      }
    }
  end

  context 'with namespace default and no options' do
    let(:params) do
      {
        'namespace' => 'default'
      }
    end

    it { is_expected.to compile.with_all_deps }

    it {
      expect(subject).to contain_exec('wait for default serviceaccount creation in default')
        .with_command('kubectl -n default get serviceaccount default -o name')
    }
  end

  context 'with namespace foo and path /bar' do
    let(:params) do
      {
        'namespace' => 'foo',
        'path' => ['/bar']
      }
    end

    it { is_expected.to compile.with_all_deps }

    it {
      expect(subject).to contain_exec('wait for default serviceaccount creation in foo')
        .with_command('kubectl -n foo get serviceaccount default -o name')
        .with_path(['/bar'])
    }
  end

  describe 'namespace naming' do
    tests = [
      ['01010', true],
      ['abc', true],
      ['A0c', true],
      ['A0c-', false],
      ['-A0c', false],
      ['A-0c', true],
      ['o123456701234567012345670123456701234567012345670123456701234567', false],
      ['o12345670123456701234567012345670123456701234567012345670123456', true],
      ['', false],
      ['a', true],
      ['0--0', true],
      ["A0c\nA0c", false],
      ['host;rm -rf /', false],
    ]

    tests.each do |namespace, expected|
      context "with namespace #{namespace}" do
        let(:params) do
          {
            'namespace' => namespace
          }
        end

        if expected
          it { is_expected.to compile.with_all_deps }

          it {
            expect(subject).to contain_exec("wait for default serviceaccount creation in #{namespace}")
              .with_command("kubectl -n #{namespace} get serviceaccount default -o name")
          }
        else
          it { is_expected.to raise_error(%r{parameter 'namespace' expects a match for Kubernetes::Namespace}) }
        end
      end
    end
  end
end
