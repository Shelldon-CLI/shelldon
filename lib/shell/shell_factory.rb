module Shelldon
  class ShellFactory
    def initialize(name, &block)
      @name = name
      register(Shell.new(name)) unless Shelldon[name]
      instance_eval(&block)
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
      cmd = Shelldon::Command.new(name, this_shell.command_list, &block)
      this_shell.command_list.register(cmd)
    end

    def script(dir)
      Shelldon::Script.from_dir(dir, this_shell).each do |cmd|
        this_shell.command_list.register(cmd)
      end
    end

    alias_method :scripts, :script

    def config(&block)
      Shelldon::ConfigFactory.create(this_shell, &block)
    end

    def opts(&block)
      OptFactory.new(@name, &block)
    end

    def command_missing(&block)
      cmd = Shelldon::Command.new(:not_found, this_shell, &block)
      this_shell.command_list.register_default(cmd)
    end

    def on_opt(opt, &block)
      if this_shell.on_opts.has_key?(opt)
        this_shell.on_opts[opt] << block
      else
        this_shell.on_opts[opt] = [block]
      end
    end

    def on_pipe(&block)
      this_shell.on_pipe = block
    end
  end
end
