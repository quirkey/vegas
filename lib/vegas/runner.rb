module Vegas
  class Runner
    attr_reader :app, :app_name, :rack_handler, :port, :host, :options
    
    ROOT_DIR   = File.expand_path(File.join('~', '.vegas'))
    START_PORT = 5678
    HOST       = '0.0.0.0'
    
    def initialize(app, app_name, set_options = {}, &block)
      @app = app
      @app_name  = app_name
      @options = set_options || {}
      define_options do |opts|
        if block_given?
          opts.separator ''
          opts.separator "#{app_name} options:"
          yield(opts, app)
        end
      end 
      @port = options[:port] || START_PORT
      @host = options[:host] || HOST
      @app.set options
      @rack_handler ||= @app.send :detect_rack_handler
      FileUtils.mkdir_p(app_dir)
      daemonize! unless options[:foreground]
      begin
        run!
      rescue RuntimeError => e
        puts "== Someone is already performing on port #{port}!"
        @port += 1
        retry
      end
      launch!
    end
    
    def app_dir
      File.join(ROOT_DIR, app_name)
    end
    
    def pid_file
      File.join(app_dir, "#{rack_handler}.pid")
    end
    
    def log_file
      File.join(app_dir, "#{app_name}.log")
    end
    
    def run!
      handler_name = rack_handler.name.gsub(/.*::/, '')
      puts "== Vegas is running / Sinatra #{Sinatra::VERSION} has taken the stage " +
            "on #{port} for #{app.environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
      rack_handler.run app, :Host => host, :Port => port do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          puts "\n== Sinatra has ended his set (crowd applauds)" unless handler_name =~/cgi/i
        end
      end
    end
    
    # Adapted from Rackup
    def daemonize!
      if RUBY_VERSION < "1.9"
        exit if fork
        Process.setsid
        exit if fork
        Dir.chdir "/"
        File.umask 0000
        STDIN.reopen  "/dev/null"
        STDOUT.reopen log_file, "a"
        STDERR.reopen log_file, "a"
      else
        Process.daemon
      end

      File.open(pid_file, 'w'){ |f| f.write("#{Process.pid}") }
      at_exit { File.delete(pid_file) if File.exist?(pid_file) }
    end
    
    def launch!
      
    end
    
    private
    def define_options
      OptionParser.new("", 24, '  ') { |opts|
        opts.banner = "Usage: #{app_name} [options]"

        opts.separator ""
        opts.separator "Vegas options:"
                
        opts.on("-s", "--server SERVER", "serve using SERVER (webrick/mongrel)") { |s|
          @rack_handler = Rack::Handler.get(s)
        }
        opts.on("-o", "--host HOST", "listen on HOST (default: #{HOST})") { |host|
          @options[:host] = host
        }

        opts.on("-p", "--port PORT", "use PORT (default: #{PORT})") { |port|
          @options[:port] = port
        }

        opts.on("-e", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
          @options[:environment] = e
        }

        opts.on("-F", "--foreground", "don't daemonize, run in the foreground") { |f|
          @options[:foreground] = true
        }
                
        yield opts if block_given?
        
        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          if app.respond_to?(:version)
            puts "#{app_name} #{app.version}"
          end
          puts "Vegas #{Vegas::VERSION}"
          exit
        end

        opts.parse! ARGV
      }
    end
    
  end
end