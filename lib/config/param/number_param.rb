# frozen_string_literal: true

module Shelldon
  class NumberParam < Param
    def val=(value)
      @val = value.to_f
    end
  end
end
