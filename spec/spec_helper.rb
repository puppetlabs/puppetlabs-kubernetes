require 'puppetlabs_spec_helper/module_spec_helper'
require 'simplecov'
require 'simplecov-json'
require 'simplecov-rcov'
require 'rspec-puppet'


SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start

at_exit { RSpec::Puppet::Coverage.report! }