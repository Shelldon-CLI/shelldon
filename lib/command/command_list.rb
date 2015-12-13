module Shelldon
  class CommandList
    attr_reader :parent
    def initialize(parent)
      @parent = parent
      @commands = {}
    end

    def register(command)
      @commands[command.name] = command
      command.aliases.each { |a| @commands[a.to_sym] = command }
    end

    def register_default(cmd)
      @default_command = cmd
    end

    def run(str)
      cmd, tokens = find(str)
      cmd.run(tokens)
    end

    def find(str)
      tokens = str.split(' ')
      key    = tokens.first.to_sym
      if @commands.has_key?(key)
        @commands[key].find(tokens[1..-1])
      else
        [@default_command, tokens.first]
      end
    end

    def is_default?(cmd)
      puts cmd.inspect unless cmd.is_a?(Command)
      cmd.name == @default_command.name
    end

    def compile_help(cmd)
      res = [["Command", cmd.christian_name]]
      res << ["Help", cmd.help] if cmd.help
      res << ["Usage", "\"#{cmd.usage}\""] if cmd.usage
      res << ["Examples", cmd.examples] if cmd.examples
      res << ["Subcommands", cmd.subcommands.values.map(&:name)] unless cmd.subcommands.empty?
      res
    end

    def help(str)
      if str.empty?
        self.to_a
      else
        cmd = find(str).first
        if cmd.show && !is_default?(cmd)
          compile_help(cmd)
        else
          raise StandardError
        end
      end
    end

    def to_a
      @commands.values.uniq
        .map { |cmd| cmd.show ? [cmd.name, cmd.aliases, cmd.help] : nil }
        .compact.sort_by { |(n, _, _)| n.to_s }
    end
  end
end
