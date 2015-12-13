module Shelldon
  class ShellFactory
    def initialize(name, &block)
      if Shelldon[name]
        @shell = Shelldon[name]
      else
        @shell = Shell.new(name)
      end
      instance_eval(&block)
    end

    def register
      Shelldon::ShellIndex << @shell
    end

    def shell(&block)
      @shell.setup(&block)
    end

    def command(name, &block)
      cmd = Shelldon::Command.new(name, @shell.command_list, &block)
      @shell.command_list.register(cmd)
    end

    def config(&block)
      Shelldon::ConfigFactory.create(@shell, &block)
    end

    def opts(&block)
      OptFactory.new(&block)
    end

    def command_missing(&block)
      cmd = Shelldon::Command.new(:not_found, @shell, &block)
      @shell.command_list.register_default(cmd)
    end
  end
end
