# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vegas"
  s.version = "0.1.11"

  s.authors = ["Aaron Quint"]
  s.date = "2009-08-30"
  s.description = "Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps. It includes a class Vegas::Runner that wraps Rack/Sinatra applications and provides a simple command line interface and launching mechanism."
  s.email = ["aaron@quirkey.com"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "History.txt",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "lib/vegas.rb",
    "lib/vegas/runner.rb",
    "test/apps.rb",
    "test/test_app/bin/test_app",
    "test/test_app/bin/test_rack_app",
    "test/test_app/test_app.rb",
    "test/test_helper.rb",
    "test/test_vegas_runner.rb",
    "vegas.gemspec"
  ]
  s.homepage = "http://code.quirkey.com/vegas"
  s.require_paths = ["lib"]
  s.summary = "Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps."

  s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
  s.add_development_dependency(%q<mocha>, ["~> 0.9.8"])
  s.add_development_dependency(%q<bacon>, ["~> 1.1.0"])
  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<sinatra>)
  s.add_development_dependency(%q<thin>)
end
