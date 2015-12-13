module Shelldon
  class OptFactory
    def initialize(&block)
      @opt_arr = []
      instance_eval(&block)
      Shelldon.opts = get_opts
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
        fail StandardError
      end
    end
  end
end
