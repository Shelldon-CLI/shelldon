# Shelldon

Shelldon is an expressive DSL for building interactive terminal applications, or REPLs (Read-Evaluate-Print-Loops).

There are some good gems out there for building command-line executables, but I couldn't find anything that built a REPL in the way that I wanted it -- and I build a lot of REPLs.

## Installation

```ruby
# Gemfile
gem 'shelldon'

$ bundle install
```
Or just `gem install shelldon` -- You know the drill.

## Usage

Here's a simple Shelldon app, available in `test_shell/simple_shell.rb`

```ruby
require 'shelldon'
require 'pp'

Shelldon.shell do
  opts do
    opt '--myopt', '-m', :boolean
  end

  config do
    # Set the config file, which can hold values one level higher than their default
    # The order of precedence for params is: Set in-session > set by command-line flag > set by config file > default
    config_file '.my-config-file'

    param :myparam do # Create a config option (a 'param')
      type :boolean   # Make it a boolean
      default false   # Make its default value false
      opt 'myopt'     # Override it with the value of command-line opt '--myopt' if present
    end
  end

  # Define a command that sets a config option
  command :set do
    # Set up some help information for the command
    help 'Set a configuration option for the remainder of the session.'
    examples ['set myparam']
    usage 'set [config_option]'

    # Define the command's action - this has access to some helpers, like 'config'
    #   You can also give the block access to the remaining (unusued) tokens of the command
    #   "Unused" meaning tokens that weren't used up to call the command in the first place
    action do |args|
      tokens                   = args.split(' ')
      config[tokens[0].to_sym] = tokens[1]
    end
  end


  # Here's a simplification of grabbing args for use in an action
  command :arg do
    help 'Show your args off!'
    action { |args| puts args }
  end

  # This command will show the active config if called witout args, or
  #   show the value of a specific option if called with an argument
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

    # This is a subcommand - it will automatically take precedence
    #   if you call a command beginning with "config save"
    subcommand :save do
      help 'Save your current configuration'
      usage 'config save'
      action { config.save }
    end
  end


  # This will show all that nice help information we've been defining.
  #   This produces a two-dimensional array, so you could make it into a table with some
  #   table-printing gem if you wanted.
  command :help do
    action { |args| pp command_list.help(args) }
    help 'Show help. Optionally specify specific command for more information.'
    usage 'help [cmd]'
    examples ['help', 'help quit']
  end

  # Define a default command - This is what happens when a command doesn't match up
  command_missing do
    action { |cmd| puts "No such command \"#{cmd}\"" }
  end

  # LASTLY, define some basic shell properties. The shell will run at the end of this block.
  shell do
    # You can make your prompt a string or a block
    prompt 'shelldon> '          # This is okay
    prompt { "shelldon#{4+2}>" } # This is okay too

    # This is the "home" directory of your shell, used for config files, history files, etc.
    home '~/.shelldon-test'

    # Enable in-session history (enabled by default)
    history true

    # Enable history logging and reloading between sessions
    history_file '.shelldon-history'

    # Error handling - You can 'accept' an error or 'reject' it.
    #   The only difference is an accepted error won't kill the shell.
    #   You can also pass a block to run when that specific command is caught.
    errors do
      reject StandardError
      accept(Interrupt) { puts '^C' }
    end
  end
end
```
## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/wwboynton/shelldon.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Let me know if you find a cool use for Shelldon!