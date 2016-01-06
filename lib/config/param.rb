module Shelldon
  class Param
    attr_accessor :pretty, :default, :opt, :validator, :adjustor, :error, :override
    attr_reader :name

    def self.create(name, &block)
      ParamFactory.create(name, &block)
    end

    def initialize(name)
      @name    = name
      @default = nil
    end

    def val
      return @val if @val
      return @override if @override
      @val = Shelldon.opts.key?(@opt) ? Shelldon.opts[@opt] : @default
    end

    def val=(value)
      value = instance_exec(value, &adjustor) if adjustor
      valid?(value) ? @val = value : fail(Shelldon::InvalidParamValueError)
    end

    def set(value)
      value = instance_exec(value, &adjustor) if adjustor
      @val  = value
    end

    def to_a
      flag =
        if @opt.nil?
          ''
        elsif @opt.length > 1
          "'--#{@opt}'"
        else
          "'-#{@opt}'"
        end
      [@name, pretty, "#{flag}"]
    end

    def pretty
      if @pretty
        instance_exec(val, &@pretty)
      else
        val.to_s
      end
    end

    def valid?(value = @val)
      return true if validator.nil?
      if instance_exec(value, &validator)
        true
      else
        @error ? fail(@error) : false
      end
    end
  end
end
