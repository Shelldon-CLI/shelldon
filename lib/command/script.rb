module Shelldon
  class Script < Command
    def self.from_dir(dir, shell)
      commands = []
      Dir["#{Pathname.new(dir).expand_path}/*"].reject { |f| File.directory?(f) }.each do |script|
        commands << self.new(script, shell.command_list)
      end
      commands
    end

    def initialize(filepath, parent, &block)
      @path = Pathname.new(filepath)
      @name        = @path.basename.to_s.split('.')[0].to_sym
      @aliases     = []
      @subcommands = {}
      @show        = true
      @parent      = parent
      self.instance_eval(&block) if block_given?
    end

    def run(tokens = [], &block)
      tokens = [tokens] unless tokens.is_a?(Array)
      cmd = "#{@path.expand_path}"
      cmd << " #{tokens.join(' ')}" unless tokens.empty?
      res = `#{@path.expand_path} #{tokens.join(' ')}`
      if block_given?
        self.instance_exec(res, &block)
      else
        puts res
      end
    end
  end
end