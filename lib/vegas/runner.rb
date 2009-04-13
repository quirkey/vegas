require 'open-uri'
require 'logger'

module Vegas
  class Runner
    attr_reader :app, :app_name, :rack_handler, :port, :host, :options
    
    ROOT_DIR   = File.expand_path(File.join('~', '.vegas'))
    PORT       = 5678
    HOST       = '0.0.0.0'
    
    def initialize(app, app_name, set_options = {}, &block)
      @app = app
      @app_name  = app_name
      @options = set_options || {}
      @rack_handler = @app.send :detect_rack_handler
      define_options do |opts|
        if block_given?
          opts.separator ''
          opts.separator "#{app_name} options:"
          yield(opts, app)
        end
      end 
      @host = options[:host] || HOST
      @app.set options
      FileUtils.mkdir_p(app_dir)
      logger.info "== Starting #{app_name}"
      find_port
      launch!
      begin
        daemonize! unless options[:foreground]      
        run!
      rescue RuntimeError => e
        logger.warn "== There was an error starting #{app_name}: #{e}"
        exit
      end
    end
    
    def app_dir
      File.join(ROOT_DIR, app_name)
    end
    
    def pid_file
      File.join(app_dir, "#{app_name}.pid")
    end
    
    def url_file
      File.join(app_dir, "#{app_name}.url")
    end
    
    def log_file
      File.join(app_dir, "#{app_name}.log")
    end
    
    def handler_name
      rack_handler.name.gsub(/.*::/, '')
    end
        
    def find_port
      if @port = options[:port]
        if !port_open?
          logger.warn "== Port #{port} is already in use. Please try another or don't use -P, for auto-port"
        end
      else
        @port = PORT
        logger.info "== Trying to start #{app_name} on Port #{port}"
        while !port_open?
          @port += 1
          logger.info "== Trying to start #{app_name} on Port #{port}"
        end
      end
    end
    
    def port_open?
      begin
        open("http://#{host}:#{port}")
        false
      rescue Errno::ECONNREFUSED => e
        true
      end
    end
    
    def run!
      rack_handler.run app, :Host => host, :Port => port do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          logger.info "== #{app_name} received INT ... stopping : #{Time.now}"
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
      Launchy.open("http://#{host}:#{port}")
    end
    
    def kill!
      pid = File.read(pid_file)
      if pid
        logger.warn "== Sending INT to #{pid}"
        Process.kill('INT', pid.to_i)
      else
        logger.warn "== pid not found at #{pid_file}"
      end
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
    
    def logger
      self.class.logger
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
        
        opts.on('-K', "--kill", "kill the running process and exit") {|k| 
          kill!
          exit
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