require 'open-uri'
require 'logger'

module Vegas
  class Runner
    attr_reader :app, :app_name, :rack_handler, :port, :host, :options
    
    ROOT_DIR   = File.expand_path(File.join('~', '.vegas'))
    PORT       = 5678
    HOST       = '0.0.0.0'
    
    def initialize(app, app_name, set_options = {}, &block)
      # initialize
      @app          = app
      @app_name     = app_name
      @options      = set_options || {}
      @rack_handler = @app.send :detect_rack_handler
      # load options from opt parser
      define_options do |opts|
        if block_given?
          opts.separator ''
          opts.separator "#{app_name} options:"
          yield(opts, app)
        end
      end
      # set app options
      @host = options[:host] || HOST
      @app.set options
      # initialize app dir
      FileUtils.mkdir_p(app_dir)
      
      logger.info "== Starting #{app_name}"
      
      check_for_running
      find_port
      write_url
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
    
    def url
      "http://#{host}:#{port}"
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
    
    def port_open?(check_url = nil)
      begin
        open(check_url || url)
        false
      rescue Errno::ECONNREFUSED => e
        true
      end
    end
    
    def write_url
      File.open(url_file, 'w') {|f| f << url }
    end
    
    def check_for_running
      if File.exists?(pid_file) && File.exists?(url_file)
        running_url = File.read(url_file)
        if !port_open?(running_url)
          logger.warn "== #{app_name} is already running at #{running_url}"
          launch!(running_url)
          exit!
        end
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
    
    def launch!(specific_url = nil)
      Launchy.open(specific_url || url)
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
    
    def status
      if File.exists?(pid_file)
        logger.info "== #{app_name} running"
        logger.info "== PID #{File.read(pid_file)}"
        logger.info "== URL #{File.read(url_file)}" if File.exists?(url_file)
      else
        logger.info "== #{app_name} not running!"
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
        
        opts.on('-S', "--status", "display the current running PID and URL then quit") {|s| 
          status
          exit!
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
          puts "sinatra #{Sinatra::VERSION}"
          puts "vegas #{Vegas::VERSION}"
          exit
        end

        opts.parse! ARGV
      }
    end
    
    
    
  end
end