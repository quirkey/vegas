begin
  require 'rack'
  require 'rbconfig'
rescue LoadError
  require 'rubygems'
  require 'rack'
end

$LOAD_PATH.unshift File.dirname(__FILE__)

module Vegas
  VERSION = "0.1.8"
  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i)
  JRUBY = !!(RbConfig::CONFIG["RUBY_INSTALL_NAME"] =~ /^jruby/i)

  autoload :Runner, 'vegas/runner'

end
