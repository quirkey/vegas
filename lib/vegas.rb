require 'rubygems'
require 'sinatra'
require 'launchy'

module Vegas
  VERSION = "0.0.1"
end

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'vegas/runner'