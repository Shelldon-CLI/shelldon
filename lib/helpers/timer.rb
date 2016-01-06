module Shelldon
  class Timer

    def self.start
      t = self.new
      t.start
      t
    end
    def initialize(strftime = '%s')
      @strftime = strftime
    end

    def start
      @start = Time.now
    end

    def stop
      res = (Time.now - @start) * 1000
      @start = nil
      Time.at(res).strftime(@strftime)
    end
  end
end