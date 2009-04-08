require 'sinatra'

module Vegas
  VERSION = "0.0.1"
end

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'vegas/admin'
require 'vegas/mounter'
require 'vegas/runner'