# This is a split-up version of the test_shell.rb
# It exists so you can screw around with when the different parts are required and ensure that
#   the order doesn't matter and multiple blocks of the same type all load in correctly.

require 'shelldon'
require_relative 'dependency_test'
require_relative 'dt_commands'
require_relative 'dt_opts'
require_relative 'dt_config'
require_relative 'test_module'

Shelldon.shell :test do
  command :superderp do
    action { puts 'beh' }
    help 'test'
  end

  config do
    param :value do
      type :string
      default 'This is the default value!'
    end
  end

  shell do
    prompt 'shelldon> '
  end
end

Shelldon.run(:test)
