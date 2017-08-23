require 'fileutils'

module Shelldon
  class FileManager
    def initialize(_file)
      @file     = config_file.expand_path
      @file_dir = config_file.dirname.expand_path
      ensure_dir(@file_dir)
      ensure_file(@file)
    end

    def ensure_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def ensure_file(file)
      File.open(file, 'w') { |f| f.write('') } unless File.exist?(file)
    end
  end
end
