# frozen_string_literal: true

require 'shelldon'

Shelldon.shell :example do
  command :test do
    help 'Run a test command to show some text. Optionally, add an arg.'
    usage 'test'
    examples ['test', 'test blah']
    action { |arg = ''| puts "This is a test! #{arg}" }
  end
end

Shelldon.run(:example)
