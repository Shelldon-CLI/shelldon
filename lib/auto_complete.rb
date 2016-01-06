# require 'abbrev'

module Shelldon
  class AutoComplete
    def initialize(shell)
      @shell = shell
    end

    def set_proc
      @comp                                    = proc { |s| auto_comp.grep(/^#{Regexp.escape(s)}/) }
      Readline.completion_append_character     = " "
      Readline.completion_proc                 = @comp
    end

    def buf
      Readline.line_buffer
    end

    def auto_comp
      Readline.completion_append_character     = ' '
      @commands = @shell.command_list.commands.map(&:to_s)
      length = buf.split(' ').length
      return @commands if length <= 1 && !buf.end_with?(' ')
      cmd, _ = @shell.command_list.find(buf)
      return [] unless cmd
      remainder = buf.gsub("#{cmd.christian_name} ", '')
      cmd.complete(remainder)
    end

    def tokenize(str)
      str.split(' ')
    end
  end
end