require 'rubygems'
require 'sinatra'

class TestApp < Sinatra::Base
  
  get '/' do
    'This is a TEST'
  end
  
end