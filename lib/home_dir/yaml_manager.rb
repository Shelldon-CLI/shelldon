
module Shelldon
  class YamlManager < FileManager

    def ensure_file(file)
      unless File.exist?(file)
        File.open(file, 'w') { |f| f.write({}.to_yaml) }
      end
    end

    def export(yaml)
      File.open(@file, 'w') { |f| f.write(yaml.to_yaml) }
    end

    def import(yaml)
      YAML.load_file(@file)
    end
  end
end