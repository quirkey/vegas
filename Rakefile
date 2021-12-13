%w[rubygems rake rake/clean rake/testtask fileutils].each { |f| require f }
require File.dirname(__FILE__) + '/lib/vegas'

VEGAS_VERSION = if ENV["DEV"]
  "#{Vegas::VERSION}.#{Time.new.to_i}"
else
  Vegas::VERSION
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

task :package => :build
task :default => :test

task "install:dev" => :build do
  system "gem install pkg/vegas-#{VEGAS_VERSION}.gem"
end
