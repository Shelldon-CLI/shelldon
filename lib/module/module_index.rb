# This allows subshelling - You can define multiple shells in one program and nest them.
# This is the opposite approach to shell-as-singleton, which makes access easy but prevents multiple shells.
# This is why all of the factories pass the shell parent into their respective products.

module Shelldon
  class ModuleIndex < Index
    def <<(mod)
      if mod.is_a?(Shelldon::Module)
        fail Shelldon::DuplicateIndexError if @index.key?(mod.name)
        @index[mod.name] = mod
      else
        fail Shelldon::NotAModuleError
      end
    end
  end
end
