source 'https://rubygems.org'

gemspec

gem 'rake', '~> 12.3'
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.0')
  gem 'jeweler', '~> 2.3'
else
  gem 'jeweler', '~> 2.1'
end
# Pin rack as 1.x to pass the unit test temporary.
# because tests are failed on rack >= 2.
# rack/showexceptions was renamed to rack/show_exceptions on rack 2.0.0.
# https://github.com/rack/rack/commit/857641d
gem 'rack', '< 2'
gem 'thin', '~> 1.7'
