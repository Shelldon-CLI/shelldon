module Shelldon
  class Opts
    include Singleton
    attr_reader :opts
    def initialize
    end

    def set(opts_arr)
      fail Shelldon::RedefineOptsError unless @opts.nil?
      @opts ||= opts_arr
    end
  end
end
