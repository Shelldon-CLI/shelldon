module Shelldon
  class Module
    attr_reader :name
    def initialize(name)
      @name            = name.to_sym
      @commands        = []
      @configs         = []
      @shell_blocks    = []
      @command_missing = []
    end

    def add_command(name, lambda)
      @commands << [name, lambda]
    end

    def add_config(lambda)
      @configs << lambda
    end

    def add_shell_block(lambda)
      @shell_blocks << lambda
    end

    def add_command_missing(name, lambda)
      @command_missing[0] = [name, lambda]
    end

    def install(shell_name)
      @commands.each do |(name, lambda)|
        Shelldon.shell(shell_name) { command(name, &lambda.to_proc) }
      end
      @configs.each do |lambda|
        Shelldon.shell(shell_name) { config(&lambda.to_proc) }
      end
      @shell_blocks.each do |lambda|
        Shelldon.shell(shell_name) { shell(&lambda.to_proc) }
      end
      @command_missing.each do |lambda|
        Shelldon.shell(shell_name) { command_missing(&lambda.to_proc) }
      end
    end
  end
end
