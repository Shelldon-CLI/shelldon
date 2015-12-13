require 'shelldon'
require 'pp'
Shelldon.shell do
  opts { opt '--debug', '-d', :boolean }

  config do
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

  command_missing do
    action { |cmd| puts "No such command \"#{cmd}\"" }
  end

  command :arg do
    help "Show your args off!"
    action { |cmd| puts cmd }
  end

  command :blah do
    action { puts config[:value] }
    subcommand :swag do
      action { puts "SWIGGITY SWAG!!!!" }
    end
  end
  command :help do
    action { |cmd| pp command_list.help(cmd) }
    help "Show help. Optionally specify specific command for more information."
    usage "help [cmd]"
    examples ['help', 'help quit']
  end

  command :config do
    help 'Show the configuration of the current session.'
    usage 'config'
    action do |cmd|
      if cmd.empty?
        pp config.to_a
      else
        param = config.find(cmd.to_sym)
        puts "#{param.name}: #{param.val}"
      end
    end

    subcommand :save do
      help 'Save your current configuration'
      usage 'config save'
      action { Shelldon.config.save_config }
    end
  end

  command :toggle do
    help "Toggle a boolean configuration option."
    action do |cmd|
      tokens = cmd.split(' ')
      cfg    = config[tokens[0].to_sym]
      raise(StandardError) unless cfg.is_a?(BooleanParam)
      config[tokens[0].to_sym].toggle
    end
  end

  command :set do
    help "Set a configuration option for the remainder of the session."

    action do |cmd|
      tokens                   = cmd.split(' ')
      config[tokens[0].to_sym] = tokens[1]
    end
  end

  shell do
    prompt 'shelldon> '
    home '~/.shelldon-test'
    history true
    history_file '.shelldon-history'

    errors do
      accept StandardError
      accept(Interrupt) { puts '^C' }
    end
    run
  end

end