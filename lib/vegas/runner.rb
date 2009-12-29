require 'open-uri'
require 'logger'
require 'optparse'

if Vegas::WINDOWS
  begin
    require 'win32/process'
  rescue 
    puts "Sorry, in order to use Vegas on Windows you need the win32-process gem:\n gem install win32-process"
  end
end

module Vegas
  class Runner
    attr_reader :app, :app_name, :rack_handler, :port, :host, :options, :args

    ROOT_DIR   = File.expand_path(File.join('~', '.vegas'))
    PORT       = 5678
    HOST       = WINDOWS ? 'localhost' : '0.0.0.0'

    def initialize(app, app_name, set_options = {}, runtime_args = ARGV, &block)
      # initialize
      @app                    = app
      @app_name               = app_name
      @options                = set_options || {}
      @runtime_args           = runtime_args
      self.class.logger.level = options[:debug] ? Logger::DEBUG : Logger::INFO
            
      @rack_handler = @app.respond_to?(:detect_rack_handler) ? 
        @app.send(:detect_rack_handler) : Rack::Handler.get('thin')
      # load options from opt parser
      if before_run = options.delete(:before_run) and before_run.is_a?(Proc)
        before_run.call(self)
      end
      
      @args = define_options do |opts|
        if block_given?
          opts.separator ''
          opts.separator "#{app_name} options:"
          yield(self, opts, app)
        end
      end

      # set app options
      @host = options[:host] || HOST
      @app.set(options) if @app.respond_to?(:set)
      @app.set(:vegas, self)
      # initialize app dir
      FileUtils.mkdir_p(app_dir)
      return if options[:start] === false
      # evaluate the launch_path
      path = if options[:launch_path] && options[:launch_path].respond_to?(:call)
        options[:launch_path].call(self)
      else
        options[:launch_path]
      end
      start(path)
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

    def start(path = nil)
      logger.info "Running with Windows Settings" if WINDOWS
      logger.info "Starting #{app_name}"
      begin
        check_for_running(path)
        find_port
        write_url
        launch!(url, path)
        daemonize! unless options[:foreground]      
        run!
      rescue RuntimeError => e
        logger.warn "There was an error starting #{app_name}: #{e}"
        exit
      end
    end

    def find_port
      if @port = options[:port]
        if !port_open?
          logger.warn "Port #{port} is already in use. Please try another or don't use -P, for auto-port"
        end
      else
        @port = PORT
        logger.info "Trying to start #{app_name} on Port #{port}"
        while !port_open?
          @port += 1
          logger.info "Trying to start #{app_name} on Port #{port}"
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

    def check_for_running(path = nil)
      if File.exists?(pid_file) && File.exists?(url_file)
        running_url = File.read(url_file)
        if !port_open?(running_url)
          logger.warn "#{app_name} is already running at #{running_url}"
          launch!(running_url, path)
          exit!
        end
      end
    end

    def run!
      rack_handler.run app, :Host => host, :Port => port do |server|
        trap(kill_command) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          logger.info "#{app_name} received INT ... stopping"
          delete_pid!
        end
      end
    end

    # Adapted from Rackup
    def daemonize!
      if RUBY_VERSION < "1.9"
        logger.debug "Parent Process: #{Process.pid}"
        exit! if fork
        logger.debug "Child Process: #{Process.pid}"
        Dir.chdir "/"
        File.umask 0000
        FileUtils.touch(log_file)
        STDIN.reopen  log_file
        STDOUT.reopen log_file, "a"
        STDERR.reopen log_file, "a"
      else
        Process.daemon
      end
      logger.debug "Child Process: #{Process.pid}"

      File.open(pid_file, 'w') {|f| f.write("#{Process.pid}") }
      at_exit { delete_pid! }
    end

    def launch!(specific_url = nil, path = nil)
      return if options[:skip_launch]
      cmd = WINDOWS ? "start" : "open"
      system "#{cmd} #{specific_url || url}#{path}"
    end

    def kill!
      pid = File.read(pid_file)
      logger.warn "Sending INT to #{pid.to_i}"
      Process.kill(kill_command, pid.to_i)
    rescue => e
      logger.warn "pid not found at #{pid_file} : #{e}"
    end

    def status
      if File.exists?(pid_file)
        logger.info "#{app_name} running"
        logger.info "PID #{File.read(pid_file)}"
        logger.info "URL #{File.read(url_file)}" if File.exists?(url_file)
      else
        logger.info "#{app_name} not running!"
      end
    end
    
    # Loads a config file at config_path and evals it in the context
    # of the @app. Also if the first line is a comment will parse it as 
    # options
    def load_config_file(config_path)
      abort "Can not find config file at #{config_path}" if !File.readable?(config_path)
      config = File.read(config_path)
      if config[/^#\\(.*)/]
        @runtime_args.shift $1.split(/\s+/)
      end
      # trim off anything after __END__
      config.sub!(/^__END__\n.*/, '')
      @app.module_eval(config_path)
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger ||= LOGGER if defined?(LOGGER)
      if !@logger
        @logger           = Logger.new(STDOUT)
        @logger.formatter = Proc.new {|s, t, n, msg| "[#{t}] #{msg}\n"}
        @logger
      end
      @logger
    end

    def logger
      self.class.logger
    end

    private
    def define_options
      OptionParser.new("", 24, '  ') do |opts|
        opts.banner = "Usage: #{app_name} [options]"

        opts.separator ""
        opts.separator "Vegas options:"

        opts.on("-s", "--server SERVER", "serve using SERVER (thin/mongrel/webrick)") { |s|
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

        opts.on("-L", "--no-launch", "don't launch the browser") { |f|
          @options[:skip_launch] = true
        }

        opts.on('-K', "--kill", "kill the running process and exit") {|k| 
          kill!
          exit
        }

        opts.on('-S', "--status", "display the current running PID and URL then quit") {|s| 
          status
          exit!
        }

        opts.on('-d', "--debug", "raise the log level to :debug (default: :info)") {|s| 
          @options[:debug] = true
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
          puts "rack #{Rack::VERSION.join('.')}"
          puts "sinatra #{Sinatra::VERSION}" if defined?(Sinatra)
          puts "vegas #{Vegas::VERSION}"
          exit
        end

      end.parse! @runtime_args
    rescue OptionParser::MissingArgument => e
      logger.warn "#{e}, run -h for options"
      exit
    end

    def kill_command
      WINDOWS ? 1 : :INT
    end

    def delete_pid!
      File.delete(pid_file) if File.exist?(pid_file)
    end
  end
  
end
