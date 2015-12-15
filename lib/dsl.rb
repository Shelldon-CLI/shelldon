module Shelldon
  def self.[](key)
    ShellIndex.instance[key.to_sym]
  end

  def self.<<(shell)
    ShellIndex.instance << shell if shell.is_a?(Shelldon::Shell)
  end

  def self.shell(name = (:default), &block)
    ShellFactory.new(name.to_sym, &block)
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
end
