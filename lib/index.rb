# frozen_string_literal: true

module Shelldon
  class Index
    include Singleton

    def self.method_missing(meth_name, *args, &block)
      if block_given?
        instance.send(meth_name, *args, &block)
      else
        instance.send(meth_name, *args)
      end
    end

    def initialize
      @index = {}
    end

    def [](key)
      @index[key.to_sym]
    end

    def []=(key, val)
      @index[key.to_sym] = val
    end

    def has_key?(key)
      @index.key?(key)
    end

    def <<(obj)
      @first = obj.name if @index.empty?
      raise Shelldon::DuplicateIndexError if @index.key?(obj.name)
      @index[obj.name] = obj
    end

    def first?(sym)
      sym = sym.to_sym unless sym.is_a?(Symbol)
      sym == @first
    end
  end
end
