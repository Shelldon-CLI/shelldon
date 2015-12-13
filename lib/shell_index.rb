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

    def <<(shell)
      if shell.is_a?(Shelldon::Shell)
        @shell_index[shell.name] = shell
      else
        fail StandardError
      end
    end
  end
end
