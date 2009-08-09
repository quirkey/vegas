%w[rubygems rake rake/clean hoe fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/vegas'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('vegas', Vegas::VERSION) do |p|
  p.developer('Aaron Quint', 'aaron@quirkey.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name       = 'quirkey'
  p.extra_deps         = [
    ['sinatra','>= 0.9.1']
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"],
    ['nokogiri', ">= 1.0.6"],
    ['bacon', ">= 1.1.0"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
