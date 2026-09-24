source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem "json", '= 2.6.1',                         require: false if Gem::Requirement.create(['>= 3.1.0', '< 3.1.3']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.6.3',                         require: false if Gem::Requirement.create(['>= 3.2.0', '< 4.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "racc", '~> 1.4.0',                        require: false if Gem::Requirement.create(['>= 2.7.0', '< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "deep_merge", '~> 1.2.2',                  require: false
  gem "voxpupuli-puppet-lint-plugins", '~> 7.0', require: false
  gem "facterdb", '~> 2.1',                      require: false if Gem::Requirement.create(['< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "facterdb", '~> 3.0',                      require: false if Gem::Requirement.create(['>= 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "metadata-json-lint", '~> 4.0',            require: false
  gem "json-schema", '< 5.1.1',                  require: false
  gem "rspec-puppet-facts", '~> 4.0',            require: false if Gem::Requirement.create(['< 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "rspec-puppet-facts", '~> 5.0',            require: false if Gem::Requirement.create(['>= 3.0.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "dependency_checker", '~> 1.0.0',          require: false
  gem "parallel_tests", '= 3.12.1',              require: false
  gem "pry", '~> 0.10',                          require: false
  gem "simplecov-console", '~> 0.9',             require: false
  gem "puppet-debugger", '~> 1.6',               require: false
  gem "rubocop", '~> 1.50.0',                    require: false
  gem "rubocop-performance", '= 1.16.0',         require: false
  gem "rubocop-rspec", '= 2.19.0',               require: false
  gem "rb-readline", '= 0.5.5',                  require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "bigdecimal", '< 3.2.2',                   require: false, platforms: [:mswin, :mingw, :x64_mingw]
end
group :development, :release_prep do
  gem "puppet-strings", '~> 4.0',         require: false
  gem "puppetlabs_spec_helper", '~> 9.0', require: false
  gem "puppet-blacksmith", '~> 7.0',      require: false
end
group :system_tests do
  # MODULES-11735: floor at 2.8.0 (not just the ~> 2.5 that would otherwise satisfy this
  # module's own bolt-based Integration job) because cat-github-actions/module_ci.yml's
  # Spec job calls matrix_from_metadata_v3 itself to build the Spec test matrix, and only
  # puppet_litmus >= 2.8.0 is Puppet-9-collection-aware. Anything looser risks silently
  # generating a Puppet-8-only Spec matrix with no Puppet 9 lane, with CI green throughout.
  gem "puppet_litmus", '~> 2.8',   require: false, platforms: [:ruby, :x64_mingw]
  gem "CFPropertyList", '< 3.0.7', require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "serverspec", '~> 2.41',     require: false
end

gems = {}

puppet_version = ENV.fetch('PUPPET_GEM_VERSION', nil)
facter_version = ENV.fetch('FACTER_GEM_VERSION', nil)
hiera_version = ENV.fetch('HIERA_GEM_VERSION', nil)
# If facter or hiera versions have been specified via the environment
# variables

gemsource_puppetcore = 'https://rubygems-puppetcore.puppet.com'

# Puppet 9 must be checked before the PUPPET_FORGE_TOKEN branch below, otherwise a
# Puppet 9 matrix leg would silently resolve the hardcoded Puppet 8 pin instead.
if puppet_version.to_s.match?(/\A(?:~>\s*)?(?:8\.99|9)/)
  # Puppet 9.0.0 is a released gem on the standard puppetcore source (confirmed:
  # puppetlabs-windows_eventlog#100's CI resolves `puppet (9.0.0)` from
  # gemsource_puppetcore with no PUPPET_GEM_SOURCE set) -- no separate internal/Twingate
  # source or prerelease-specific version matching is needed for it anymore. Uses the
  # literal array form (not location_for) because this file's location_for is the
  # 2-arg variant that doesn't accept/merge a :source option.
  gems['puppet'] = [puppet_version, { require: false, source: gemsource_puppetcore }]
  gems['facter'] = [facter_version, { require: false, source: gemsource_puppetcore }]
# If PUPPET_FORGE_TOKEN is set then use authenticated source for both puppet and facter, since facter is a transitive dependency of puppet
# Otherwise, do as before and use location_for to fetch gems from the default source
elsif !ENV['PUPPET_FORGE_TOKEN'].to_s.empty?
  gems['puppet'] = ['~> 8.11', { require: false, source: gemsource_puppetcore }]
  gems['facter'] = ['~> 4.11', { require: false, source: gemsource_puppetcore }]
else
  gems['puppet'] = location_for(puppet_version)
  gems['facter'] = location_for(facter_version) if facter_version
end
gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby


# Fixed version for puppet-modulebuilder gem, as newer version of this gem does not include tooling folder.
# We will keep this until we find a solution to either move the tooling folder in to some other folder or get rid of it altogether.
gem 'puppet-modulebuilder', '1.1.0'
