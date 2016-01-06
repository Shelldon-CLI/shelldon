# This allows subshelling - You can define multiple shells in one program and nest them.
# This is the opposite approach to shell-as-singleton, which makes access easy but prevents multiple shells.
# This is why all of the factories pass the shell parent into their respective products.

module Shelldon
  class ShellIndex
    include Singleton

    def self.method_missing(meth_name, *args, &block)
      if block_given?
        instance.send(meth_name, *args, &block)
      else
        instance.send(meth_name, *args)
      end
    end

    def initialize
      @shell_index = {}
    end

    def [](key)
      @shell_index[key.to_sym]
    end

    def has_key?(key)
      @shell_index.has_key?(key)
    end

    def <<(shell)
      if shell.is_a?(Shelldon::Shell)
        @first = shell.name if @shell_index.empty?
        @shell_index[shell.name] = shell
      else
        fail Shelldon::NotAShellError
      end
    end

    def first?(sym)
      sym = sym.to_sym unless sym.is_a?(Symbol)
      sym == @first
    end
  end
end
