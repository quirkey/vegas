dependencies = %w{
  bacon
  mocha
  sinatra
  rack/test
  nokogiri
}

begin
  dependencies.each {|f| require f }
rescue LoadError
  require 'rubygems'
  dependencies.each {|f| require f }
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'vegas.rb')
require File.join(File.dirname(__FILE__), 'test_apps.rb')


module TestHelper
  def rackup(app)
    Rack::Test::Session.new(app)
  end
  
  def vegas(*args, &block)
    Vegas::Runner.any_instance.stubs(:daemonize!).once
    Rack::Handler::Thin.stubs(:run).once    
    @vegas = Vegas::Runner.new(*args, &block)
  end
  
  def body
    last_response.body.to_s
  end

  def instance_of(klass)
    lambda {|obj| obj.is_a?(klass) }
  end
  
  def exist_as_file
    lambda {|obj| File.exist?(obj) }
  end
  
  def have_matching_file_content(content_regex)
    lambda {|obj| 
      File.exist?(obj) && File.read(obj).match(content_regex) 
    }
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