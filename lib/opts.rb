module Shelldon
  class Opts
    include Singleton
    attr_reader :opts
    def initialize
    end

    def set(opts_arr)
      raise StandardError unless @opts.nil?
      @opts ||= opts_arr
    end
  end
end