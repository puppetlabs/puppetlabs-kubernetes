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
  # TODO(MODULES-11735): temporary — the latest release (8.0.0) still pins puppet-lint
  # ~> 4.0, which conflicts with voxpupuli-puppet-lint-plugins ~> 7.0 (puppet-lint ~> 5.1,
  # needed for Puppet 9). main already relaxed this to puppet-lint ~> 5.0 but hasn't been
  # released yet. Swap back to a released gem once it ships.
  gem "puppetlabs_spec_helper", git: 'https://github.com/puppetlabs/puppetlabs_spec_helper.git', branch: 'main', require: false
  gem "puppet-blacksmith", '~> 7.0',      require: false
end
group :system_tests do
  # TODO(MODULES-11735): temporary — depends on an unmerged puppet_litmus branch that adds
  # --collection-platform-exclude to matrix_from_metadata_v3 (keeps a platform in the Puppet 8
  # acceptance lane while dropping it from Puppet 9, for platforms Puppet 9 doesn't ship an
  # agent for). Pinned unconditionally: the acceptance matrix passes that flag on every run,
  # so falling back to a released gem would fail the job on an unrecognised option. Swap back
  # once that support ships.
  gem "puppet_litmus", git: 'https://github.com/puppetlabs/puppet_litmus.git', branch: 'main', require: false, platforms: [:ruby, :x64_mingw]
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

# TODO(MODULES-11735): Puppet 9 (8.99.x) prereleases are served from an internal source
# injected via PUPPET_GEM_SOURCE (see cat-github-actions module_ci.yml, which fetches it
# over Twingate); '' is truthy in Ruby, so guard on emptiness rather than falling back
# with `||`. This has to be checked before the PUPPET_FORGE_TOKEN branch below, otherwise
# a Puppet 9 matrix leg would silently resolve the hardcoded Puppet 8 pin instead.
if puppet_version.to_s.match?(/\A(?:~>\s*)?(?:8\.99|9)/)
  puppet9_source = ENV['PUPPET_GEM_SOURCE'].to_s.empty? ? gemsource_puppetcore : ENV['PUPPET_GEM_SOURCE']
  if ENV['PUPPET_GEM_SOURCE'].to_s.empty?
    # No public source publishes an 8.99.x/9.x gem, so resolution below is certain to
    # fail. Say so plainly: without this, bundler reports only "Could not find gem
    # 'puppet (>= 8.99.0.a, < 9)'" followed by every 7.x/8.x version it did find,
    # which reads like a version-constraint bug rather than a missing setting.
    warn 'WARNING: PUPPET_GEM_SOURCE is not set, so the Puppet 9 (8.99.x) prerelease ' \
         "cannot be resolved (falling back to #{puppet9_source}, which does not carry it). " \
         'In CI this secret must be configured on the repository; see MODULES-11735.'
  end
  puppet9_req = puppet_version.to_s.match?(/\d+\.\d+\.\d/) ? [puppet_version] : ['>= 8.99.0.a', '< 9']
  gems['puppet'] = [*puppet9_req, { require: false, source: puppet9_source }]
  # Honour FACTER_GEM_VERSION when the workflow sets one (module_ci.yml passes '~> 4.10');
  # only fall back to a floor when it is unset. Don't hardcode a floor above the newest
  # published facter -- that is unsatisfiable whenever puppet9_source is the puppetcore
  # fallback rather than the internal prerelease source.
  gems['facter'] = if facter_version.to_s.empty?
                     ['>= 4.10', { require: false, source: puppet9_source }]
                   else
                     [facter_version, { require: false, source: puppet9_source }]
                   end
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
