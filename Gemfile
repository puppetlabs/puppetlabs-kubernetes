source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gem 'metadata-json-lint'
gem 'puppet', '~> 4'
gem 'puppetlabs_spec_helper', '>= 1.0.0'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'rspec-puppet'
gem "rspec-retry"
gem 'thor'
gem 'semantic_puppet'
gem 'simplecov'
gem 'simplecov-json'
gem 'simplecov-rcov'
gem "beaker-puppet_install_helper", :require => false
gem "beaker-rspec"
gem "parallel_tests"
gem "beaker", "~> 2.0"
gem 'rspec_junit_formatter'

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
  gem 'rake', '~> 10.0'
else
  # rubocop requires ruby >= 1.9
  gem 'rubocop'
end
