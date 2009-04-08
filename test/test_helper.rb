require 'rubygems'
require 'bacon'
require 'sinatra'
require 'rack/test'

require File.join(File.dirname(__FILE__), '..', 'lib', 'vegas.rb')

require 'nokogiri'

module TestHelper
  def rackup(app)
    Rack::Test::Session.new(app)
  end
  
  def body
    last_response.body.to_s
  end

  def instance_of(klass)
    lambda {|obj| obj.is_a?(klass) }
  end

  def html_body
    body =~ /^\<html/ ? body : "<html><body>#{body}</body></html>"
  end

end

Bacon::Context.send(:include, TestHelper)

class Should

  def have_element(search, content = nil)
    satisfy "have element matching #{search}" do
      doc = Nokogiri.parse(@object.to_s)
      node_set = doc.search(search)
      if node_set.empty?
        false
      else
        collected_content = node_set.collect {|t| t.content }.join(' ')
        case content
        when Regexp
          collected_content =~ content
        when String
          collected_content.include?(content)
        when nil
          true
        end
      end
    end
  end
end