require 'shelldon'
require 'pp'
require 'auto_complete'
Shelldon.shell :test do
  command_missing do
    action { |cmd| puts "No such command \"#{cmd}\"" }
  end

  modules [:test_module]

  shell do
    home '~/.shelldon-test'
    history true
    history_file '.shelldon-history'

    errors do
      accept StandardError
      # accept(Interrupt) { puts '^C' }
    end
  end
end
