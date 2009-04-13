require 'rubygems'
require 'sinatra'
require 'launchy'

$LOAD_PATH.unshift File.dirname(__FILE__)

module Vegas
  VERSION = "0.0.1"
  
  autoload :Runner, 'vegas/runner'
end