module Shelldon
  class Param
    attr_accessor :pretty, :default, :opt, :validator, :adjustor, :error
    attr_reader :name

    def self.create(name, &block)
      ParamFactory.create(name, &block)
    end

    def initialize(name)
      @name    = name
      @default = nil
    end


    def val
      if @val.nil?
        if Shelldon.opts.has_key?(@opt)
          Shelldon.opts[@opt]
        else
          @default
        end
      else
        @val
      end
    end

    def val= (value)
      value = self.instance_exec(value, &adjustor) if adjustor
      valid?(value) ? @val=value : raise(StandardError)
    end

    def set(value)
      value = self.instance_exec(value, &adjustor) if adjustor
      @val  = value
    end

    def pretty
      if @pretty
        self.instance_exec(val, &@pretty)
      else
        val.to_s
      end
    end

    def valid?(value = @val )
      return true if validator.nil?
      if self.instance_exec(value, &validator)
        true
      else
        @error ? raise(@error) : false
      end
    end

  end
end