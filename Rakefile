%w[rubygems rake rake/clean hoe fileutils].each { |f| require f }
require File.dirname(__FILE__) + '/lib/vegas'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('vegas') do |p|
  p.version              = Vegas::VERSION
  p.developer('Aaron Quint', 'aaron@quirkey.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.summary              = "Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps."
  p.description          = %{Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps. It includes a class Vegas::Runner that wraps Rack/Sinatra applications and provides a simple command line interface and launching mechanism.}
  p.rubyforge_name       = 'quirkey'
  p.extra_deps         = [
    ['rack','= 1.0']
  ]
  p.extra_dev_deps = [
    ['bacon', ">= 1.1.0"],
    ['mocha', ">= 0.9.7"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
