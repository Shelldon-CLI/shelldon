module Shelldon
  class HistoryFile
    def initialize(history_file)
      @file = history_file
    end

    def load
      hist = File.open(@file, 'r') {|f| f.read }.split("\n")
      hist.each {|line| Readline::HISTORY << line}
    end

    def << (line)
      File.open(@file, 'a') { |f| f.write("#{line}\n") }
    end

    def truncate(lines)
      File.open(@file, 'w') do
        arr      = f.read.split("\n")
        last_100 = arr[-lines..-1].join("\n")
        f.write(last_100)
      end
    end
  end
end