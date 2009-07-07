require 'rubygems'
require 'sinatra'

$LOAD_PATH.unshift File.dirname(__FILE__)

module Vegas
  VERSION = "0.0.3"
  WINDOWS = !!(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i)
  
  autoload :Runner, 'vegas/runner'
end

