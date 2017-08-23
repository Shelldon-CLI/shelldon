require 'pathname'

module Shelldon
  class Config
    attr_reader :opts
    attr_accessor :on_opts, :config_file_manager

    def initialize(shell)
      @shell   = shell
      @opt_arr = []
      @on_opts = {}
      @config  = {}
    end

    def opts=(arr)
      @opts ||= arr
    end

    def setup
      load_config_file if @config_file_manager
    end

    def toggle(key)
      fail Shelldon::NotBooleanError unless @config[key].is_a?(Shelldon::BooleanParam)
      @config[key].toggle
    end

    def register(param)
      fail Shelldon::DuplicateParamError if @config.key?(param.name)
      @config[param.name] = param
    end

    def [](key)
      @config.key?(key) ? @config[key].val : nil
    end

    def find(key)
      @config.key?(key) ? @config[key] : nil
    end

    def []=(key, val)
      check_param(key, true)
      @config[key].val = (val)
    end

    def set(key, val)
      @config[key].set(val)
    end

    def to_a
      @config.values.map(&:to_a).sort_by(&:first)
    end

    def to_hash
      Hash[@config.map { |_, param| [param.name, param.val] }]
    end

    def check_param(key, raise = false)
      if @config.key?(key.to_sym)
        true
      else
        raise ? fail(Shelldon::NoSuchParamError) : false
      end
    end

    def to_yaml
      to_hash.to_yaml
    end

    def import(hash)
      # We load all of the params in first without validation, to avoid param dependency issues
      # Then we validate them all
      hash.each do |k, v|
        key = k.to_sym
        if @config.key?(key)
          set(key, v) unless @config[key].override ||
              (Shelldon.opts &&Shelldon.opts.key?(@config[key].opt))
        else
          fail(Shelldon::NoSuchParamError)
        end
      end
      hash.each do |k, _|
        @config[k].valid? unless @config[k].val == @config[k].default
      end
    end

    def load_config_file
      import(@config_file_manager.import) if @config_file_manager
    end

    def save
      @config_file_manager.export if @config_file_manager
    end
  end
end
