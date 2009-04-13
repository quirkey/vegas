# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{vegas}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Quint"]
  s.date = %q{2009-04-13}
  s.description = %q{Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps.}
  s.email = ["aaron@quirkey.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "lib/vegas.rb", "lib/vegas/runner.rb", "test/test_apps.rb", "test/test_helper.rb", "test/test_vegas_runner.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://code.quirkey.com/vegas}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{quirkey}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps.}
  s.test_files = ["test/test_apps.rb", "test/test_helper.rb", "test/test_vegas_runner.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.1"])
      s.add_runtime_dependency(%q<launchy>, [">= 0.3.3"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.0.6"])
      s.add_development_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<sinatra>, [">= 0.9.1"])
      s.add_dependency(%q<launchy>, [">= 0.3.3"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<nokogiri>, [">= 1.0.6"])
      s.add_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0.9.1"])
    s.add_dependency(%q<launchy>, [">= 0.3.3"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<nokogiri>, [">= 1.0.6"])
    s.add_dependency(%q<bacon>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
