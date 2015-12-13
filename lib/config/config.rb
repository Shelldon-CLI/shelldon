require 'pathname'

module Shelldon
  class Config
    attr_reader :opts
    attr_accessor :on_opts, :config_file_handler

    def initialize(&block)
      @opt_arr = []
      @on_opts = {}
      @config = {}
    end

    def opts= (arr)
      @opts ||= arr
    end

    def setup
      load_config_file
    end

    def register(param)
      raise StandardError if @config.has_key?(param.name)
      @config[param.name] = param
    end

    def [](key)
      @config.has_key?(key) ? @config[key].val : nil
    end

    def find(key)
      @config.has_key?(key) ? @config[key] : nil
    end

    def []= (key, val)
      check_param(key, true)
      @config[key].val = (val)
    end

    def set (key, val)
      @config[key].set(val)
    end

    def to_a
      @config.map { |k, v| [k, v.pretty] }.sort_by(&:first)
    end

    def to_hash
      Hash[@config.map { |_, param| [param.name, param.val] }]
    end

    def check_param(key, raise = false)
      if @config.has_key?(key.to_sym)
        true
      else
        raise ? raise(StandardError) : false
      end
    end

    def to_yaml
      self.to_hash.to_yaml
    end

    def import(hash)
      # We load all of the params in first without validation, to avoid param dependency issues
      # Then we validate them all
      hash.each do |k, v|
        key = k.to_sym
        @config.has_key?(key) ? set(key, v) : raise(StandardError)
      end
      hash.each do |k, _|
        @config[k].valid? unless @config[k].val == @config[k].default
      end
    end

    def load_config_file
      @config_file_handler.import if @config_file_handler
    end

    def save_config
      @config_file_handler.export if @config_file_handler
    end


  end
end