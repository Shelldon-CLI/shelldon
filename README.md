# <img src="http://www.wesleyboynton.com/wp-content/uploads/2016/04/shelldon.png" width="100"> Shelldon

[![Gem Version](https://badge.fury.io/rb/shelldon.svg)](https://badge.fury.io/rb/shelldon)

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

Shelldon is made to be dead-simple to use. Here's a breakdown of the usage!

Start defining a shell like this:

``` ruby
Shelldon.shell :example do
end
Shelldon.run(:example)

```

### Commands

Define a command with a `command` block:

``` ruby
Shelldon.shell :example do
  command :test do
    aliased 'test_command'
    help "Run a test command to show some text. Optionally, add an arg."
    usage "test"
    examples ['test', 'test blah']
    action { |arg = ''| puts "This is a test! #{arg}" }
  end
end
Shelldon.run(:example)

```

### Sub-Commands

You can nest commands into other commands with the `subcommand` block. This is great for organizing functionality. You can retain the functionality of your higher-level commands, or if you want a higher-level command to act as a placeholder you can just tell Shelldon so!

For instance, you could run the command `test foobar` like this:
``` ruby
  command :test do
    placeholder

    subcommand :foobar do
      help "Print out 'Foobar!'"
      action {puts "Foobar!"}
    end
  end
```

### Default Command ("No Such Command Found")
You can use the `command_missing` block to define behaviour when a command isn't explicitly registered. This can be anything from writing "No Such Command" to doing a similarity-search to passing the command to some other resource.

``` ruby
command_missing do
  action { |cmd| puts "No such command \"#{cmd}\"" }
end
```

### Configuration
What good is a shell without config? The `config` block will allow you to set up parameters, validate and adjust input, set a configuration yml file, and interact with command-line opts.

Here's an example that implements the bash 'set -o vi/emacs' functionality in the shell

``` ruby

config do
  config_file '.shelldon_config'

  param :'-o' do
    type :string
    default 'emacs'
    # adjust runs before validate, and can 'fix' your input. In this case, allow 'vim' for 'vi'
    adjust { |s| s.to_s.downcase.strip.gsub('vim', 'vi') }
    # validate looks for a 'true' result, but in this case we're also using it to take action
    validate do |s|
      return false unless s == 'emacs' || s == 'vi'
      if s == 'emacs'
        Readline.emacs_editing_mode; true
      else
        Readline.vi_editing_mode; true
      end
    end
  end
end
```


## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/wwboynton/shelldon.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Let me know if you find a cool use for Shelldon!