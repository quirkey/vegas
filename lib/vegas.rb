require 'rubygems'
require 'sinatra'
require 'launchy'

# check for windows
if RUBY_PLATFORM =~ /(mingw|bccwin|wince)/i
  begin
    require 'win32/process'
  rescue 
    puts "Sorry, in order to use Vegas on Windows you need the win32-process gem:\n gem install win32-process"
  end
end

$LOAD_PATH.unshift File.dirname(__FILE__)

module Vegas
  VERSION = "0.0.2"
  
  autoload :Runner, 'vegas/runner'
end