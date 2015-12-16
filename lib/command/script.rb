module Shelldon
  class Script < Command
    def self.from_dir(dir)
      commands = []
      Dir[Pathname.new(dir).expand_path].reject(&:directory?).each do |script|
        commands << Shelldon::Script.new(script, this_shell.command_list)
      end
    end


    def initialize(filepath, parent, &block)
      @path = Pathname.new(filepath)
      raise StandardError if @path.basename.start_with?('.')
      @name        = path.basename.split('.')[0]
      @aliases     = []
      @subcommands = {}
      @show        = true
      @parent      = parent
      instance_eval(&block)
    end

    def run(tokens = [])
      tokens = [tokens] unless tokens.is_a?(Array)
      instance_exec(tokens.join(' '), &@action)


      res = system(@path.expand_path)
      self.instance_exec(res, &block) if block_given?
    end
  end
end