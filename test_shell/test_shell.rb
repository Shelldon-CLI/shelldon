require 'shelldon'
require 'pp'
Shelldon.shell do

  config do
    opts { opt '--debug', '-d', :boolean }

    param :debug_mode do
      type :boolean
      default false
      opt 'd'
    end

    param :value do
      type :string
      default "This is the default value!"
    end


  end

  command :blah do
    action { puts Shelldon.config[:value] }
    subcommand :swag do
      action { puts "SWIGGITY SWAG!!!!" }
    end
  end

  shell do
    prompt "shelldon> "
    home '~/.shelldon-test'
    history true
    history_file ''
    acceptable_errors [StandardError]
    run
  end

end