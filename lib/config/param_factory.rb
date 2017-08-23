require 'config/param/string_param'

module Shelldon
  class ParamFactory
    attr_writer :default, :opt

    def self.create(config, name, &block)
      new(config, name, &block)
    end

    def initialize(config, name, &block)
      @config = config
      @name = name
      instance_eval(&block) if block_given?
      register
    end

    private

    def default(default_value)
      @default = default_value
    end

    def override(value)
      @override = value
    end

    def opt(opt)
      @opt = opt
    end

    def register
      manufacture
      if @param
        @param.pretty    = @pretty_proc if @pretty_proc
        @param.default   = @default unless @default.nil?
        @param.override  = @override if @override
        @param.opt       = @opt if @opt
        @param.error     = @error if @error
        @param.validator = @validator if @validator
        @param.adjustor  = @adjustor if @adjustor
        @config.register(@param)
      else
        fail Shelldon::RegisterNilParamError
      end
    end

    def pretty(&block)
      @pretty_proc = block
    end

    def validate(error = nil, &block)
      @error     = error if error
      @validator = block
    end

    def adjust(&block)
      @adjustor = block
    end

    def manufacture
      case @type
      when :string, :str
        @param = Shelldon::StringParam.new(@name)
      when :boolean, :bool
        @param = Shelldon::BooleanParam.new(@name)
      when :array, :arr
        @param = Shelldon::ArrayParam.new(@name)
      when :number, :num
        @param = Shelldon::NumberParam.new(@name)
      else
        @param = Shelldon::StringParam.new(@name)
      end
    end

    def type(t)
      @type = t.to_sym
    end
  end
end
