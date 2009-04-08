module Vegas
  class Admin < Sinatra::Default
   
    set :app_file, __FILE__
    set :root, File.join(File.dirname(__FILE__), '..', '..')
    
    get '/' do
      haml :index
    end
    
  end
end