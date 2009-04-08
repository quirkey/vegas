require 'test_helper'
require 'test_apps'

describe 'Vegas::Mounter' do
  
  before do
    Vegas::Mounter.clear_mounts!
  end
  
  describe 'mount!' do
    
    describe 'when the path already has been taken' do
      it 'raises an error' do
        Vegas::Mounter.mount!('/test', TestApp1.new)
        lambda {
          Vegas::Mounter.mount!('/test', TestApp2.new)
        }.should.raise(Vegas::MountError)
      end
    end
    
    describe 'when the path is free' do
      before do
        Vegas::Mounter.mount!('/test', TestApp1.new)
      end

      it 'adds an entry to mounts' do
        Vegas::Mounter.mounts.length.should.equal 1
      end
      
      it 'sets the key to the path' do
        Vegas::Mounter.mounts.keys.should.include '/test'
      end
      
    end
    
    describe 'the path is specified without a /' do
      before do
        Vegas::Mounter.mount!('test', TestApp1.new)
      end

      it 'adds the path and app to mounts' do
        Vegas::Mounter.mounts.length.should.equal 1
      end
            
      it 'adds the slash before adding to mounts' do
        Vegas::Mounter.mounts.keys.should.include '/test'
      end
    end
  end
  
  describe 'invoked with rack' do
    
    describe 'with no mounts' do
      
      describe 'get /' do
        
        it 'redirects to /vegas' do
          
        end
        
      end
      
      describe 'get /somethingelse' do
        
        it 'should 404' do
          
        end
        
        it 'should display vegas 404' do
          
        end
      end
      
      describe 'get /vegas' do
        
        it 'should display the vegas index' do
          
        end
        
      end
    end
    
    describe 'with apps mounted' do
      
      describe 'get /' do
        
      end
      
      describe 'get /mountedapp' do
        
      end
      
      describe 'get /mountedapp/route' do
        
      end
      
      describe 'get /somethingnotfound' do
        
      end
      
      describe 'get /vegas' do
        
      end
      
    end
    
  end
  
end