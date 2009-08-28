require File.join(File.dirname(__FILE__), 'test_helper.rb')

Vegas::Runner::ROOT_DIR = File.join(File.dirname(__FILE__), 'tmp', '.vegas')

describe 'Vegas::Runner' do
  before do
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'tmp'))
    @log = StringIO.new
    Vegas::Runner.logger = Logger.new(@log)
  end

  describe '.new' do

    describe 'with basic usage' do
      before do
        vegas(TestApp1, 'vegas_test_app_1', {:skip_launch => true, :sessions => true}, ["route","--debug"])
      end

      it "sets app" do
        @vegas.app.should == TestApp1
      end

      it "sets app name" do
        @vegas.app_name.should == 'vegas_test_app_1'
      end

      it "stores options" do
        @vegas.options[:sessions].should.be.true
      end

      it "puts unparsed args into args" do
        @vegas.args.should == ["route"]
      end

      it "parses options into @options" do
        @vegas.options[:debug].should.be.true
      end

      it "writes the app dir" do
        @vegas.app_dir.should exist_as_file
      end

      it "writes a url with the port" do
        @vegas.url_file.should have_matching_file_content(/0.0.0.0\:#{@vegas.port}/)
      end

    end

    describe 'with a sinatra app' do
      before do
        TestApp1.expects(:detect_rack_handler).once.returns(Rack::Handler::Mongrel)
        Rack::Handler::Mongrel.stubs(:run)
        vegas(TestApp1, 'vegas_test_app_1', {:skip_launch => true, :sessions => true}, ["route","--debug"])
      end
    
      it 'sets the rack handler automaticaly' do
        @vegas.rack_handler.should == Rack::Handler::Mongrel
      end
    
      it "sets options on the app" do
        @vegas.app.sessions.should.be.true
      end

    end

    describe 'with a simple rack app' do
      before do
        vegas(RackApp1, 'rack_app_1', {:skip_launch => true, :sessions => true})
      end
      
      it "sets default rack handler to thin" do
        @vegas.rack_handler.should == Rack::Handler::Thin
      end
      
    end

  end

end

