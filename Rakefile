%w[rubygems rake rake/clean rake/testtask fileutils].each { |f| require f }
require File.dirname(__FILE__) + '/lib/vegas'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = %q{vegas}
    s.version = Vegas::VERSION
    s.authors = ["Aaron Quint"]
    s.date = %q{2009-08-30}
    s.summary              = "Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps."
    s.description          = %{Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps. It includes a class Vegas::Runner that wraps Rack/Sinatra applications and provides a simple command line interface and launching mechanism.}
    s.email = ["aaron@quirkey.com"]
    s.homepage = %q{http://code.quirkey.com/vegas}
    s.rubyforge_project = %q{quirkey}
    
    s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
    
    s.add_development_dependency(%q<mocha>,   ["~> 0.9.8"])
    s.add_development_dependency(%q<bacon>,   ["~> 1.1.0"])
    s.add_development_dependency(%q<sinatra>, ["~> 0.9.4"])
    
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

task :default => :test
