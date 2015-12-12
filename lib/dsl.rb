module Shelldon

  def self.[](key)
    @@shell_index[key.to_sym]
  end

  def self.<< (shell)
    @@shell_index << shell if shell.is_a?(Shelldon::Shell)
  end

  def self.shell(&block)
    ShellFactory.new(&block)
  end

  def self.config(&block)
    if block_given?
      Shelldon::Shell.instance.config.setup(&block)
    else
      Shelldon::Shell.instance.config
    end
  end

  def self.opts
    Shelldon::Shell.opts
  end

  class ShellFactory

    def initialize(&block)
      self.instance_eval(&block)
    end

    def opt(*args)

    end

    def acceptable_errors(arr)
      Shelldon::Shell.instance.acceptable_errors = arr
    end

    def command_list
      Shelldon::Shell.instance.command_list
    end

    def command(name, &block)
      cmd = Shelldon::Command.new(name, &block)
      Shelldon::Shell.command_list.register(cmd)
    end

    def shell(&block)
      Shelldon::Shell.setup(&block)
    end

    def config(&block)
      Shelldon::ConfigFactory.create(&block)
    end

    def opts
      Shelldon::Shell.instance.config.opts
    end

    def command_missing(&block)
      cmd = Shelldon::Command.new(:not_found, &block)
      Shelldon::Shell.command_list.register_default(cmd)
    end

  end
end