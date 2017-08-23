class String
  def start_and_end_with?(str)
    self.start_with?(str) && self.end_with?(str)
  end
end