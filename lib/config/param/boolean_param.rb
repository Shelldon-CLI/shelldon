module Shelldon
  class BooleanParam < Param

    def initialize(name)
      @validator ||= Proc.new { |v| v.is_a?(TrueClass) || v.is_a?(FalseClass) }
      super
    end

    def fix_val(v)
      if valid?(v)
        v
      elsif v.is_a?(String)
        v = v.downcase.strip
        return false if v == 'false'
        return true if v == 'true'
      elsif v.nil?
        nil
      else
        v ? true : false
      end
    end

    def val= (v)
      @val = fix_val(v)
    end


    def toggle
      @val = !@val
    end
  end
end