
module Shelldon
  class YamlManager < FileManager
    def ensure_file(file)
      File.open(file, 'w') { |f| f.write({}.to_yaml) } unless File.exist?(file)
    end

    def export(yaml)
      File.open(@file, 'w') { |f| f.write(yaml.to_yaml) }
    end

    def import(_yaml)
      YAML.load_file(@file)
    end
  end
end
