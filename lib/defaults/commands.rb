Shelldon.shell do
  command :help do
    action { |cmd| pp Shelldon::Shell.instance.command_list.help(cmd) }
    help "Show help. Optionally specify specific command for more information."
    usage "help [cmd]"
    examples ['help', 'help quit']
  end

  command :config do
    help 'Show the configuration of the current session.'
    usage 'config'
    action do |cmd|
      if cmd.empty?
        pp Shelldon::Shell.instance.config.to_a
      else
        param = Shelldon::Shell.instance.config.find(cmd.to_sym)
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
end