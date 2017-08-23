# frozen_string_literal: true

class String
  def start_and_end_with?(str)
    start_with?(str) && end_with?(str)
  end
end
