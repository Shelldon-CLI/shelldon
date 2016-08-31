module Shelldon
  class ModuleFactory
    def initialize(name, &block)
      @name = name
      register Shelldon::Module.new(name) unless Shelldon.modules.has_key?(name)
      instance_exec(@name, &block.to_proc)
    end

    def this_module
      Shelldon.modules[@name]
    end

    def command(name, &block)
      this_module.add_command(name, block)
    end

    def config(&block)
      this_module.add_config(block)
    end

    def shell(&block)
      this_module.add_shell_block(block)
    end

    def command_missing(&block)
      this_module.add_command_missing(block)
    end

    def register(mod)
      Shelldon.modules << mod
    end
  end
end
