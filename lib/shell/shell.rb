require 'readline'
require_relative '../auto_complete'
# require 'byebug'

module Shelldon
  class Shell
    attr_accessor :command_list, :config, :accept_errors, :reject_errors, :on_opts, :on_pipe
    attr_reader :home, :name, :config, :logger
    attr_writer :history, :history_file

    def initialize(name, &block)
      @accept_errors = {}
      @reject_errors = {}
      @name          = name
      @errors        = {}
      @history       = true
      @command_list  = CommandList.new(self)
      @config        = Shelldon::Config.new(self)
      @autocomplete  = Shelldon::AutoComplete.new(self) # if defined?(Shelldon::AutoComplete)
      @on_opts       = {}
      setup(&block) if block_given?
    end

    def shell
      self
    end

    def self.method_missing(meth_name, *args, &block)
      Shelldon::ShellIndex[:default].send(meth_name, *args, &block)
    end

    def self.[](key)
      fail Shelldon::NoSuchShellError unless Shelldon::ShellIndex[key]
      Shelldon::ShellIndex[key]
    end

    def setup(&block)
      instance_eval(&block)
      FileUtils.mkdir_p(@home.to_s) unless File.exist?(@home) if @home
      Dir.chdir(@home) if @home
      if @auto_complete_proc
        Readline.completion_proc = @auto_complete_proc
      else
        @autocomplete.set_proc if @autocomplete
      end

      if @history_path && @history
        @history_helper = Shelldon::HistoryFile.new(@history_path)
      end
      @config.load_config_file
    end

    def quit
      @history_helper.save if @history_helper
      puts "\n"
      exit 0
    end

    def run_opt_conditions
      @on_opts.each do |opt, procs|
        if Shelldon.opts && Shelldon.opts.key?(opt)
          procs.each do |proc|
            instance_eval(&proc)
          end
        end
      end
    end

    def handle_piped_input
      return if $stdin.tty?
      if @on_pipe
        instance_exec($stdin.readlines, &@on_pipe)
      else
        $stdin.readlines.each { |cmd| run_commands(cmd) }
      end
      exit 0
    end

    def run
      @history_helper.load
      run_opt_conditions
      handle_piped_input
      instance_eval(&@startup) if @startup
      begin
        run_repl
      rescue *@accept_errors.keys => e
        print_error(e)
        @logger.warn(e)
        on_error(e, @accept_errors[e.class], :accept)
        retry
      rescue *@reject_errors.keys => e
        print_error(e)
        @logger.fatal(e)
        on_error(e, @reject_errors[e.class], :reject)
      rescue StandardError => e
        print_error(e)
        puts "Reached fatal error. G'bye!"
      ensure
        # puts "Last exception: #{$!.inspect}" #if @config[:debug_mode]
        # puts "Last backtrace: \n#{$@.join("\n")}"# if @config[:debug_mode]
        instance_eval(&@shutdown) if @shutdown
        @history_helper.save if @history_helper
        quit
      end
    end

    def on_error(e, proc, type = nil)
      run_accept_error(e) if type == :accept
      run_reject_error(e) if type == :reject
      instance_exec(e, &proc) if proc
    end

    def print_error(e)
      return unless @config[:debug_mode]
      puts "Hit Error! (#{e.class})"
      msg = (e.message == e.class.to_s ? '' : "(#{e.message})")
      puts msg unless msg == '()'
      puts e.backtrace.join("\n")
    end

    def get_prompt
      if @prompt_setter
        instance_eval(&@prompt_setter)
      else
        @prompt || '> '
      end
    end

    def run_repl
      while cmd = Readline.readline(get_prompt, true)
        run_commands(cmd)
      end
    end

    def opts
      @config.opts
    end

    def opts=(arr)
      @config.opts = arr
    end

    def run_commands(commands)
      commands.split(';').each { |cmd| run_command(cmd) }
    end

    def run_command(cmd)
      @history_helper << cmd if @history_helper
      run_precommand(cmd)
      @command_list.run(cmd)
      run_postcommand(cmd)
    end

    def run_precommand(cmd)
      instance_exec(cmd, &@pre_command) if @pre_command
    end

    def run_postcommand(cmd)
      instance_exec(cmd, &@post_command) if @post_command
    end

    def run_accept_error(error)
      instance_exec(error, &@on_accept_error) if @on_accept_error
    end

    def run_reject_error(error)
      instance_exec(error, &@on_reject_error) if @on_reject_error
    end

    def init(&block)
      instance_eval(&block)
    end

    # DSL

    private

    def history(history)
      @history = history
    end

    def history_file(file)
      @history_path = file
    end

    def log_file(filepath, freq = 'daily')
      filepath = Pathname.new(filepath).expand_path.to_s
      @logger = Logger.new(filepath, freq)
    end

    def prompt(str = '> ', &block)
      if block_given?
        @prompt_setter = block
      else
        @prompt = str
      end
    end

    def shutdown(&block)
      @shutdown = block
    end

    def startup(&block)
      @startup = block
    end

    def pre_command(&block)
      @pre_command = block
    end

    def post_command(&block)
      @post_command = block
    end

    def home(path)
      @home = Pathname.new(path).expand_path
    end

    def errors(&block)
      error_factory = Shelldon::ErrorFactory.new(&block)
      @accept_errors, @reject_errors = error_factory.get
      @on_accept_error = error_factory.on_accept_error
      @on_reject_error = error_factory.on_reject_error
    end

    def autocomplete(&block)
      @auto_complete_proc = block.to_proc
    end
  end
end
