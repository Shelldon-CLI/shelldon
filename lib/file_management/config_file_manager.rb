require 'fileutils'

module Shelldon
  class ConfigFileManager < YamlManager
    def initialize(shell, config_file)
      @shell = shell
      @file = config_file
    end

    def ensure_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def export
      super(@shell.config)
    end

    def setup
      @file     = @file.expand_path
      @file_dir = @file.dirname.expand_path
      ensure_dir(@file_dir)
      ensure_file(@file)
    end

    def import
      setup
      super(@file)
    end
  end
end
