module Shelldon
  class Command
    attr_reader :name, :aliases, :subcommands, :parent

    def initialize(name, parent, &block)
      @name        = name
      @aliases     = []
      @subcommands = {}
      @show        = true
      @parent      = parent
      instance_eval(&block)
    end

    def christian_name
      if @parent.is_a?(Shelldon::Command)
        "#{@parent.christian_name} #{@name}"
      else
        @name
      end
    end

    def command_list
      @parent
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
      tokens = [tokens] unless tokens.is_a?(Array)
      instance_exec(tokens.join(' '), &@action)
    end

    def valid?(input)
      return true unless @validator
      if instance_exec(input, &@validator)
        true
      else
        @error ? fail(@error) : false
      end
    end

    def auto_complete(_input)
      @autocomplete = @subcommands.values
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
      [@name, @aliases.map{|a| "'#{a}'"}.join(', '), @help || '']
    end

    def timeout(i = nil)
      i ? @timeout = i : @timeout
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
      @action = proc { fail StandardError }
    end
  end
end
