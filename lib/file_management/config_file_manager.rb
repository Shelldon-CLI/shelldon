require 'fileutils'

module Shelldon
  class ConfigFileManager < YamlManager
    def initialize(shell, config_file)
      @shell = shell
      @config_file = config_file
    end

    def ensure_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def ensure_file(file)
      File.open(file, 'w') { |f| f.write({}.to_yaml) } unless File.exist?(file)
    end

    def export
      super(@shell.config)
    end

    def setup
      @file     = @config_file.expand_path
      @file_dir = @config_file.dirname.expand_path
      ensure_dir(@file_dir)
      ensure_file(@file)
    end

    def import
      setup
      super(@file)
    end
  end
end
