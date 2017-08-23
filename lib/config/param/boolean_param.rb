# frozen_string_literal: true

module Shelldon
  class BooleanParam < Param
    def initialize(name)
      @validator ||= proc { |v| v.is_a?(TrueClass) || v.is_a?(FalseClass) }
      super
    end

    def fix_val(v)
      if valid?(v) || v.nil?
        v
      elsif v.is_a?(String)
        return true   if v == true || v =~ /(true|t|yes|y|1)$/i
        return false  if v == false || v =~ /(false|f|no|n|0)$/i
        raise(ArgumentError, "invalid value for Boolean: \"#{v}\"")
      else
        v ? true : false
      end
    end

    def val=(v)
      @val = fix_val(v)
    end

    def toggle
      @val = !@val
    end
  end
end
