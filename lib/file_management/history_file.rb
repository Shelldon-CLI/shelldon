# frozen_string_literal: true

module Shelldon
  class HistoryFile < FileManager
    def initialize(history_file)
      @file = history_file
      ensure_dir(Pathname.new(@file).dirname)
      ensure_file(@file)
    end

    def load
      @file = Pathname.new(@file).expand_path
      hist  = File.open(@file, 'r', &:read).split("\n")
      hist.each do |line|
        Readline::HISTORY.push(line)
      end
    end

    def <<(line)
      File.open(@file, 'a') { |f| f.write("#{line}\n") }
    end

    def save; end

    def truncate(lines)
      File.open(@file, 'w') do
        arr      = f.read.split("\n")
        last_100 = arr[-lines..-1].join("\n")
        f.write(last_100)
      end
    end
  end
end
