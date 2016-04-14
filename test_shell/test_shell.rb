require 'shelldon'
require 'pp'
require 'auto_complete'
Shelldon.shell :test do
  opts do
    opt '--debug', '-d', :boolean
    opt '--help', '-h', :boolean
  end

  on_opt 'help' do
    puts "Here's some help!"
    exit 0
  end

  scripts '~/test/test-scripts'

  command :script do
    action { '' }
    scripts '~/test/scripts2'
  end

  config do
    config_file '.shelldon_config'

    param :debug_mode do
      type :boolean
      default false
      opt 'd'
    end

    param :'-o' do
      type :string
      default 'emacs'
      adjust { |s| s.to_s.downcase.strip.gsub('vim', 'vi') }
      validate do |s|
        return false unless s == 'emacs' || s == 'vi'
        if s == 'emacs'
          Readline.emacs_editing_mode; true
        else
          Readline.vi_editing_mode; true
        end
      end
    end

    param :value do
      type :string
      default 'This is the default value!'
    end
  end

  command_missing do
    action { |cmd| puts "No such command \"#{cmd}\"" }
  end

  command :arg do
    help 'Show your args off!'
    action { |args| puts args }
  end

  command :blah do
    action { puts config[:value] }
    autocomplete %w(dingus dugbus)

    subcommand :swiggity do
      action { puts 'beh' }
    end

    subcommand :swag do
      action { puts 'SWIGGITY SWAG!!!!' }

      subcommand :foobar do
        action { puts 'BUNGIS' }
      end
    end
  end

  command :help do
    action { |args| pp command_list.help(args) }
    help 'Show help. Optionally specify specific command for more information.'
    usage 'help [cmd]'
    examples ['help', 'help quit']
  end

  command :config do
    help 'Show the configuration of the current session.'
    usage 'config'
    action do |args|
      if args.empty?
        pp config.to_a
      else
        param = config.find(args.to_sym)
        puts "#{param.name}: #{param.val}"
      end
    end

    subcommand :save do
      help 'Save your current configuration'
      usage 'config save'
      action { config.save }
    end
  end

  command :set do
    help 'Set a configuration option for the remainder of the session.'

    action do |args|
      tokens                   = args.split(' ')
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
      # accept(Interrupt) { puts '^C' }
    end
  end
end

Shelldon.run(:test)
