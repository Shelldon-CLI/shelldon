module Shelldon
  class Shell
    attr_accessor :command_list, :config,
                  :accept_errors, :reject_errors
    attr_reader :history, :home, :name

    def initialize(name, &block)
      @accept_errors = {}
      @reject_errors = {}
      @name          = name
      @errors        = {}
      @history       = true
      @command_list  = CommandList.new(self)
      @config        = Config.new
      setup(&block) if block_given?
    end

    def self.method_missing(meth_name, *args, &block)
      Shelldon::ShellIndex[:default].send(meth_name, *args, &block)
    end

    def setup(&block)
      self.instance_eval(&block)
      Dir.mkdir_p(@home) unless File.exist?(@home)
      Dir.chdir(@home) if @home
      @history_helper = HistoryFile.new(@history_file) if @history_file
      @history_helper.load
      @config.load_config_file(@home)
    end

    def quit
      @history_helper.save if @history_helper
      puts "\n"
      exit 0
    end

    def run
      self.instance_eval(&@startup) if @startup
      begin
        run_repl
      rescue *@accept_errors.keys => e
        on_error(e, @accept_errors[e.class])
        retry
      rescue *@reject_errors.keys => e
        on_error(e, @reject_errors[e.class])
      rescue Exception => e
        print_error(e)
        puts "Reached fatal error. G'bye!"
        raise e
      ensure
        self.instance_eval(&@shutdown) if @shutdown
        quit
      end
    end

    def on_error(e, proc)
      self.instance_exec(e, &proc)
    end

    def print_error(e)
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
      run_precommand(cmd)
      @command_list.run(cmd)
      run_postcommand(cmd)
    end

    def run_precommand(cmd)
      self.instance_exec(cmd, &@pre_command) if @pre_command
    end

    def run_postcommand(cmd)
      self.instance_exec(cmd, &@post_command) if @post_command
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

    def history_file(filename)
      @history_file = filename
    end

    def errors(&block)
      @accept_errors, @reject_errors =
        Shelldon::ErrorFactory.new(&block).get
    end

  end
end