# frozen_string_literal: true

require 'bundler'
require 'puppet_litmus/rake_tasks' if Gem.loaded_specs.key? 'puppet_litmus'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks' if Gem.loaded_specs.key? 'puppet-strings'

PuppetLint.configuration.send('disable_relative')
PuppetLint.configuration.send('disable_params_empty_string_assignment')
# MODULES-11735: new in voxpupuli-puppet-lint-plugins 7.0 (needed for Puppet 9 support).
# Flags several pre-existing non-Optional params defaulting to undef in manifests/init.pp;
# fixing those would change the type contract, which is out of scope for a Puppet 9 support
# change. Disabled rather than touched.
PuppetLint.configuration.send('disable_params_not_optional_with_undef')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.ignore_paths = [".vendor/**/*.pp", ".bundle/**/*.pp", "pkg/**/*.pp", "spec/**/*.pp", "tests/**/*.pp", "types/**/*.pp", "vendor/**/*.pp"]

require 'rspec/core/rake_task'
namespace :kubernetes do
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'spec/acceptance/**{,/*/**}/*_spec.rb'
    t.rspec_opts = "--tag integration"
  end
end
