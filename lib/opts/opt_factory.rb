# frozen_string_literal: true

module Shelldon
  class OptFactory
    def initialize(name, &block)
      @name    = name
      @opt_arr = []
      instance_eval(&block)
      Shelldon.opts = get_opts if Shelldon.first?(@name)
    end

    def get_opts
      @opt_arr.empty? ? [] : Getopt::Long.getopts(*@opt_arr)
    end

    private

    def opt(*args, type)
      @opt_arr << [args.first, args[1] || '', getopt_constant(type)]
    end

    def getopt_constant(sym)
      case sym.to_sym
      when :boolean
        Getopt::BOOLEAN
      when :required
        Getopt::REQUIRED
      else
        raise Shelldon::NoSuchOptTypeError
      end
    end
  end
end
