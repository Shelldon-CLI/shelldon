module Shelldon
  class ShellFactory
    def initialize(name, &block)
      @name = name
      setup_vars
      register(Shell.new(name)) unless Shelldon[name]
      instance_eval(&block)
      make_it_rain
    end

    def setup_vars
      @new_opts        = []
      @new_configs     = []
      @new_on_opts     = []
      @new_commands    = []
      @new_script_dirs = []
    end

    def make_it_rain
      make_opts
      make_configs
      make_on_opts
      make_commands
      make_scripts
      make_command_missing
    end

    def register(shell)
      Shelldon::ShellIndex << shell
    end

    def this_shell
      Shelldon[@name]
    end

    def shell(&block)
      this_shell.setup(&block)
    end

    def command(name, &block)
      @new_commands << [name, block]
    end

    def make_commands
      @new_commands.each do |(name, block)|
        cmd = Shelldon::Command.new(name, this_shell.command_list, &block)
        this_shell.command_list.register(cmd)
      end
    end

    def script(dir)
      @new_script_dirs << dir
    end

    def make_scripts
      @new_script_dirs.each do |dir|
        Shelldon::Script.from_dir(dir, this_shell).each do |cmd|
          this_shell.command_list.register(cmd)
        end
      end
    end

    alias_method :scripts, :script

    def config(&block)
      @new_configs << block
    end

    def make_configs
      @new_configs.each do |block|
        Shelldon::ConfigFactory.create(this_shell, &block)
      end
    end

    def opts(&block)
      @new_opts << block
    end

    def make_opts
      @new_opts.each { |block| OptFactory.new(@name, &block) }
    end

    def command_missing(&block)
      @new_command_missing = block if block_given?
    end

    def make_command_missing
      return unless @new_command_missing
      cmd = Shelldon::Command.new(:not_found, this_shell, &@new_command_missing.to_proc)
      this_shell.command_list.register_default(cmd)
    end

    def on_opt(opt, &block)
      @new_on_opts << [opt, block]
    end

    def make_on_opts
      @new_on_opts.each do |(opt, block)|
        if this_shell.on_opts.key?(opt)
          this_shell.on_opts[opt] << block
        else
          this_shell.on_opts[opt] = [block]
        end
      end
    end

    def on_pipe(&block)
      this_shell.on_pipe = block
    end
  end
end
