module Shelldon
  class Command
    attr_reader :name, :aliases, :subcommands

    def initialize(name, parent = Shelldon::Shell.command_list, &block)
      @name        = name
      @aliases     = []
      @subcommands = {}
      @show        = true
      @parent      = parent
      self.instance_eval(&block)
    end

    def christian_name
      if @parent.is_a?(Shelldon::Command)
        "#{@parent.christian_name} #{@name}"
      else
        @name
      end
    end

    def run(tokens = [])
      tokens = [tokens] unless tokens.is_a?(Array)
      self.instance_exec(tokens.join(' '), &@action)
    end

    def valid?(input)
      return true unless @validator
      if self.instance_exec(input, &@validator)
        true
      else
        @error ? raise(@error) : false
      end
    end

    def auto_complete(input)
      ac = @subcommands.values
    end

    def has_subcommand?
      !@subcommands.empty?
    end

    def find(tokens)
      tokens = tokens.split(' ') if tokens.is_a?(String)
      return [self, tokens] if tokens.empty?

      if @subcommands.has_key?(tokens.first.to_sym)
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
      bool.nil? ? @show : @show=(bool ? true : false)
    end

    def help(str = nil)
      str ? @help=str : @help
    end

    def usage(str = nil)
      str ? @usage=str : @usage
    end

    def examples(arr = nil)
      if arr
        arr       = [arr] unless arr.is_a?(Array)
        @examples = arr
      else
        @examples
      end

    end

    def timeout(i = nil)
      i ? @timeout=i : @timeout
    end

    # DSL Only
    private

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
      @subcommands[name.to_sym] = Shelldon::Command.new(name, self, &block)
    end

    def completion(arr = [], &block)
      @completion = (block_given? ? block : arr)
    end

    def placeholder
      @action = Proc.new { raise StandardError }
    end
  end
end
