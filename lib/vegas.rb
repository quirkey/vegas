begin
  require 'sinatra'
rescue LoadError
  require 'rubygems'
  require 'sinatra'
end

$LOAD_PATH.unshift File.dirname(__FILE__)

module Vegas
  VERSION = "0.0.4"
  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i)
  
  autoload :Runner, 'vegas/runner'
end

