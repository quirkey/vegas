class TestApp1 < Sinatra::Default
  
  get '/' do
    'TestApp1 Index'
  end
  
  get '/route' do
    'TestApp1 route'
  end
end


class TestApp2 < Sinatra::Default
  
  get '/' do
    'TestApp2 Index'
  end
  
  get '/route' do
    'TestApp2 route'
  end
end