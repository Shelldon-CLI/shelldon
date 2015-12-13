require 'byebug'
require 'readline'

module Shelldon
  class Shell
    attr_accessor :command_list, :config,
                  :accept_errors, :reject_errors
    attr_reader :home, :name
    attr_writer :history, :history_file

    def initialize(name, &block)
      @accept_errors = {}
      @reject_errors = {}
      @name          = name
      @errors        = {}
      @history       = true
      @command_list  = CommandList.new(self)
      @config        = Config.new(self)
      setup(&block) if block_given?
    end

    def self.method_missing(meth_name, *args, &block)
      Shelldon::ShellIndex[:default].send(meth_name, *args, &block)
    end

    def setup(&block)
      instance_eval(&block)
      FileUtils.mkdir_p(@home.to_s) unless File.exist?(@home)
      Dir.chdir(@home) if @home
      Readline.completion_proc = proc { [] }
      if @history_path && @history
        @history_helper = Shelldon::HistoryFile.new(@history_path)
        @history_helper.load if @history_helper
      end
      @config.load_config_file
      run
    end

    def quit
      @history_helper.save if @history_helper
      puts "\n"
      exit 0
    end

    def run
      instance_eval(&@startup) if @startup
      begin
        run_repl
      rescue *@accept_errors.keys => e
        print_error(e)
        on_error(e, @accept_errors[e.class])
        retry
      rescue *@reject_errors.keys => e
        print_error(e)
        on_error(e, @reject_errors[e.class])
      rescue StandardError => e
        print_error(e)
        puts "Reached fatal error. G'bye!"
        raise e
      ensure
        instance_eval(&@shutdown) if @shutdown
        @history_helper.save if @history_helper
        quit
      end
    end

    def on_error(e, proc)
      instance_exec(e, &proc)
    end

    def print_error(e)
      return false unless @config[:debug_mode]
      puts e.message
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
      @history_helper << cmd
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
      @accept_errors, @reject_errors =
          Shelldon::ErrorFactory.new(&block).get
    end
  end
end
