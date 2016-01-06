module Shelldon
  class YamlManager < FileManager
    def ensure_file(file)
      File.open(file, 'w') { |f| f.write({}.to_yaml) } unless File.exist?(file)
    end

    def export(yaml)
      File.open(@file, 'w') { |f| f.write(yaml.to_yaml) }
    end

    def import(_yaml)
      reset unless valid?
      YAML.load_file(@file)
    end

    def valid?
      File.exist?(@file) && !File.zero?(@file)
    end

    def reset
      FileUtils.mv(@file, "#{@file}-#{Time.now.strftime('%y%m%d-%k%M%S')}.invalid")
      ensure_file(@file)
    end
  end
end
