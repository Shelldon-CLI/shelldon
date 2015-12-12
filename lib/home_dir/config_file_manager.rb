require 'fileutils'

module Shelldon
  class ConfigFileManager < YamlManager
    def initialize(config_file)
      @file     = config_file.expand_path
      @file_dir = config_file.dirname.expand_path
      ensure_dir(@file_dir)
      ensure_file(@file)
    end

    def ensure_dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def ensure_file(file)
      unless File.exist?(file)
        File.open(file, 'w') { |f| f.write({}.to_yaml) }
      end
    end

    def export
      super(Shelldon.config)
    end

    def import
      Shelldon.config.import(super(@file))
    end
  end
end