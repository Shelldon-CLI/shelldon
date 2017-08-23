# frozen_string_literal: true

module Shelldon
  def self.[](key)
    ShellIndex.instance[key.to_sym]
  end

  def self.<<(shell)
    ShellIndex.instance << shell if shell.is_a?(Shelldon::Shell)
  end

  def self.first?(sym)
    ShellIndex.first?(sym)
  end

  def self.shell(name = :default, &block)
    if shell_factory_index.key?(name)
      shell_factory_index[name].load(&block)
    else
      ShellFactory.new(name.to_sym, &block)
    end
  end

  def self.opts=(opts_arr)
    Shelldon::Opts.instance.set(opts_arr)
  end

  def self.opts
    Shelldon::Opts.instance.opts
  end

  def self.method_missing(meth, *args, &block)
    ShellIndex.instance[:default].send(meth, *args, &block)
  end

  def self.confirm(*args)
    Shelldon::Confirmation.ask(*args)
  end

  def self.has_shell?(sym)
    sym = sym.to_sym unless sym
    ShellIndex.instance.key?(sym)
  end

  def self.module(name, &block)
    ModuleFactory.new(name.to_sym, &block)
  end

  def self.module_index
    Shelldon::ModuleIndex.instance
  end

  def self.modules
    module_index
  end

  def self.shell_factory_index
    Shelldon::ShellFactoryIndex.instance
  end

  def self.run(shell_name = :default)
    shell_factory_index[shell_name].run
  end
end
