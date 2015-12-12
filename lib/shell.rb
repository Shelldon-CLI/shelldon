module Shelldon
  class Shell
    include Singleton
    attr_accessor :command_list, :config, :acceptable_errors
    attr_reader :history

    def initialize(&block)
      @acceptable_errors = []
      @history           = true
      @command_list      = CommandList.new
      @config            = Config.new
      setup(&block) if block_given?
    end

    def self.method_missing(meth_name, *args, &block)
      self.instance.send(meth_name, *args, &block)
    end

    def setup(&block)
      self.instance_eval(&block)
    end

    def run
      @config.load_config_file
      self.instance_eval(&@startup) if @startup
      begin
        run_repl
      rescue *@acceptable_errors => e
        error(e)
        retry
      rescue => e
        error(e)
      ensure
        self.instance_eval(&@shutdown) if @shutdown
      end
    end

    def error(e)
      if @config[:debug_mode]
        puts e.message
        puts e.backtrace.join("\n")
      end
    end

    def get_prompt
      if @prompt_setter
        self.instance_eval(&@prompt_setter)
      else
        @prompt || '> '
      end
    end

    def run_repl
      while cmd = Readline.readline(get_prompt, false)
        run_commands(cmd)
      end
      puts "\n"
    end

    def opts
      @config.opts
    end

    def opts=(arr)
      @config.opts = arr
    end

    def run_commands(commands)
      commands.split(';').each do |cmd|
        self.instance_exec(cmd, &@pre_command) if @pre_command
        @command_list.run(cmd)
        self.instance_exec(cmd, &@post_command) if @post_command
      end
    end

    def init(&block)
      self.instance_eval(&block)
    end

    # DSL
    private

    def history(bool = true)
      @history = bool
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

    def acceptable_errors(arr)
      @acceptable_errors = arr
    end

    def home(path)
      @home = Pathname.new(path).expand_path
    end

    def history_file()

  end
end