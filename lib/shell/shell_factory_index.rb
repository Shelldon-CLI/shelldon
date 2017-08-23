# frozen_string_literal: true

# This allows subshelling - You can define multiple shells in one program and nest them.
# This is the opposite approach to shell-as-singleton, which makes access easy but prevents multiple shells.
# This is why all of the factories pass the shell parent into their respective products.

module Shelldon
  class ShellFactoryIndex < Index
    def <<(shell_factory)
      if shell_factory.is_a?(Shelldon::ShellFactory)
        raise Shelldon::DuplicateIndexError if @index.key?(shell_factory.name)
        @index[shell_factory.name] = shell_factory
      else
        raise Shelldon::NotAShellFactoryError
      end
    end
  end
end
