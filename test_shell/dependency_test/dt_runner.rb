# This is a split-up version of the test_shell.rb
# It exists so you can screw around with when the different parts are required and ensure that
#   the order doesn't matter.

require 'shelldon'
require_relative 'dependency_test'
require_relative 'dt_commands'
require_relative 'dt_opts'
require_relative 'dt_config'

Shelldon[:test].run
