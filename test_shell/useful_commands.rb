# frozen_string_literal: true

Shelldon.shell do
  command :toggle do
    help 'Toggle a boolean configuration option.'
    action do |cmd|
      tokens = cmd.split(' ')
      cfg    = config[tokens[0].to_sym]
      raise(StandardError) unless cfg.is_a?(BooleanParam)
      config[tokens[0].to_sym].toggle
    end
  end
end
