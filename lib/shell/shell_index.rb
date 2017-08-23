# This allows subshelling - You can define multiple shells in one program and nest them.
# This is the opposite approach to shell-as-singleton, which makes access easy but prevents multiple shells.
# This is why all of the factories pass the shell parent into their respective products.

module Shelldon
  class ShellIndex < Index
    def <<(shell)
      if shell.is_a?(Shelldon::Shell)
        fail Shelldon::DuplicateIndexError if @index.key?(shell.name)
        @first = shell.name if @index.empty?
        @index[shell.name] = shell
      else
        fail Shelldon::NotAShellError
      end
    end
  end
end
