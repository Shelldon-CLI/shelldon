module Shelldon
  class ShellFactory
    attr_reader :name

    def initialize(name, &block)
      @started = false
      @name    = name
      Shelldon.shell_factory_index << self
      setup_vars
      registered_shell = register(Shell.new(name)) unless Shelldon[name]
      load(&block) if block_given?
      registered_shell
    end

    def load(&block)
      instance_eval(&block) if block_given?
    end

    def setup_vars
      @modules         = []
      @new_opts        = []
      @new_configs     = []
      @new_on_opts     = []
      @new_commands    = []
      @new_script_dirs = []
    end

    def run
      make_it_rain
      Shelldon[@name].run
    end

    def make_it_rain
      return true if @started
      install_modules
      make_opts
      make_configs
      this_shell.config.setup
      make_on_opts
      make_commands
      make_scripts
      make_command_missing
      @started = true
    end

    def register(shell)
      Shelldon::ShellIndex << shell
    end

    def this_shell
      Shelldon[@name]
    end

    def shell(&block)
      this_shell.setup(&block)
    end

    def command(name, &block)
      @new_commands << [name, block]
    end

    def make_commands
      @new_commands.each do |(name, block)|
        cmd = nil
        if this_shell.command_list[name.to_sym].nil?
          cmd = Shelldon::Command.new(name, this_shell.command_list, &block)
        else
          cmd = this_shell.command_list[name.to_sym]
          cmd.load(&block)
        end
        this_shell.command_list.register(cmd)
      end
    end

    def script(dir)
      @new_script_dirs << dir
    end

    def make_scripts
      @new_script_dirs.each do |dir|
        Shelldon::Script.from_dir(dir, this_shell).each do |cmd|
          this_shell.command_list.register(cmd)
        end
      end
    end

    alias_method :scripts, :script

    def modules(mods)
      mods     = [mods] unless mods.is_a?(Array)
      @modules += mods.map(&:to_sym)
    end

    def install_modules
      @modules.each do |mod_name|
        if Shelldon.modules.has_key?(mod_name)
          Shelldon.modules[mod_name].install(@name)
        else
          raise Shelldon::NoSuchModuleError mod_name
        end

      end
    end

    def config(&block)
      @new_configs << block
    end

    def make_configs
      @new_configs.each do |block|
        Shelldon::ConfigFactory.create(this_shell, &block)
      end
    end

    def opts(&block)
      @new_opts << block
    end

    def make_opts
      @new_opts.each { |block| OptFactory.new(@name, &block) }
    end

    def command_missing(&block)
      @new_command_missing = block if block_given?
    end

    def make_command_missing
      return unless @new_command_missing
      cmd = Shelldon::Command.new(:not_found, this_shell, &@new_command_missing.to_proc)
      this_shell.command_list.register_default(cmd)
    end

    def on_opt(opt, &block)
      @new_on_opts << [opt, block]
    end

    def make_on_opts
      @new_on_opts.each do |(opt, block)|
        if this_shell.on_opts.key?(opt)
          this_shell.on_opts[opt] << block
        else
          this_shell.on_opts[opt] = [block]
        end
      end
    end

    def on_pipe(&block)
      this_shell.on_pipe = block
    end
  end
end
