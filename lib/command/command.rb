require 'timeout'

module Shelldon
  class Command
    attr_reader :name, :aliases, :subcommands, :parent, :autocomplete, :times_out
    SINGLE_QUOTE = "'"
    DOUBLE_QUOTE = '"'

    def initialize(name, parent, &block)
      @name        = name
      @aliases     = []
      @subcommands = Hash.new{ |h, k| h[k.to_sym] = Shelldon::Command.new(k, self) {} }
      @show        = true
      @parent      = parent
      @times_out   = true
      instance_eval(&block)
    end

    def load(&block)
      instance_eval(&block) if block_given?
    end

    def christian_name
      if @parent.is_a?(Shelldon::Command)
        "#{@parent.christian_name} #{@name}"
      else
        @name
      end
    end

    def fuzzy(cmd)
      FuzzyMatch.new(command_list.to_a.map(&:first).map(&:to_s)).find(cmd)
    end

    def command_list
      @parent.command_list
    end

    def shell
      # This will recurse through subcommands until
      # eventually .shell gets called on the command list :)
      @parent.shell
    end

    def config
      shell.config
    end

    def run(tokens = [])
      begin
        tokens = [tokens] unless tokens.is_a?(Array)
        Timeout.timeout(timeout_length, Shelldon::TimeoutError) do
          instance_exec(tokens, &@action)
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end

    def valid?(input)
      return true unless @validator
      if instance_exec(input, &@validator)
        true
      else
        @error ? fail(@error) : false
      end
    end

    def has_subcommand?
      !@subcommands.empty?
    end

    def find(tokens)
      tokens = tokens.split(' ') if tokens.is_a?(String)
      return [self, tokens] if tokens.empty?

      if @subcommands.key?(tokens.first.to_sym)
        key = tokens.shift.to_sym
        @subcommands[key].find(tokens)
      else
        [self, tokens]
      end
    end

    def first_token(arr)
      arr.first.to_sym
    end

    def register
      command_list.register(self)
    end

    # DSL

    def show(bool = nil)
      bool.nil? ? @show : @show = (bool ? true : false)
    end

    def help(str = nil)
      str ? @help = str : @help
    end

    def usage(str = nil)
      str ? @usage = str : @usage
    end

    def examples(arr = nil)
      if arr
        arr       = [arr] unless arr.is_a?(Array)
        @examples = arr
      else
        @examples
      end
    end

    def to_a
      [@name, @aliases.map { |a| "'#{a}'" }.join(', '), @help || '']
    end

    def sub_to_a
      @subcommands.values.uniq
        .map { |cmd| cmd.show ? cmd.to_a : nil }
        .compact.sort_by { |(n, _, _)| n.to_s }
    end

    def timeout_length(_i = nil)
      return 0 unless @times_out
      return shell.config[:timeout] unless @timeout
      @timeout
    end

    def complete(buf)
      length = buf.split(' ').length
      res    = (length <= 1 && !buf.end_with?(' ')) ? subcommand_list : []
      res    += instance_exec(buf, &@autocomplete) if @autocomplete
      res
    end

    # DSL Only

    private

    def times_out(bool = true)
      @times_out = bool
    end

    def timeout(i = nil)
      i ? @timeout = i : @timeout
    end

    def validate(error, &block)
      @error     = error if error
      @validator = block
    end

    def aliased(names)
      [names].flatten.each { |n| @aliases << n }
    end

    def action(&block)
      @action = block
    end

    def subcommand(name, &block)
      subcommand = @subcommands[name.to_sym]
      subcommand.load(&block)
      subcommand
    end

    def subcommand_list
      return [] if @subcommands.empty?
      @subcommands.keys.map(&:to_s)
    end

    def script(dir)
      Shelldon::Script.from_dir(dir, self).each do |cmd|
        @subcommands[cmd.name.to_sym] = cmd
      end
    end

    alias_method :scripts, :script

    def completion(arr = [], &block)
      @completion = (block_given? ? block : arr)
    end

    def placeholder
      @action = proc { fail Shelldon::NotImplementedError }
    end

    def autocomplete(arr = nil, &block)
      if block_given?
        @autocomplete = block.to_proc
      else
        arr           ||= []
        @autocomplete = proc { arr }
      end
    end

    def self.tokenize(str)
      statements = str.split(/;(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).map(&:strip)
      statements.map do |statement|
        statement.split(/\s(?=(?:[^"]|"[^"]*")*$)/).map do |token|
          if token.start_and_end_with?(DOUBLE_QUOTE) ||
            token.start_and_end_with?(SINGLE_QUOTE)

            token = token[1..-2]
          end
          token
        end
      end
    end
  end
end
