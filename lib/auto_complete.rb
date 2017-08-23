# frozen_string_literal: true

# require 'abbrev'

module Shelldon
  class AutoComplete
    def initialize(shell)
      @shell = shell
    end

    def set_proc
      @comp                                = proc { |s| auto_comp.grep(/^#{Regexp.escape(s)}/) }
      Readline.completion_append_character = ' '
      Readline.completion_proc             = @comp
    end

    def buf
      Readline.line_buffer
    end

    def auto_comp
      Readline.completion_append_character = ' '
      @commands                            = @shell.command_list.commands.map(&:to_s)
      last_command                         = Command.tokenize(buf)
      last_command                         = last_command.last if last_command.last.is_a?(Array)
      length                               = last_command.length
      return @commands if length <= 1 && !buf.end_with?(' ')
      cmd, = @shell.command_list.find(last_command)
      return [] unless cmd
      remainder = last_command.join(' ').gsub("#{cmd.christian_name} ", '')
      cmd.complete(remainder)
    end
  end
end
