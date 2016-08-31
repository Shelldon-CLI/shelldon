module Shelldon
  class Error < StandardError
    def initialize(msg = nil)
      @msg = msg
    end
  end

  class ConfirmationError < Error
    define_method(:message) { 'User did not provide a valid confirmation.' }
  end

  class NotImplementedError < Error
    define_method(:message) { 'This command has not been implemented, or is a placeholder' }
  end

  class NoSuchCommandError < Error
    define_method(:message) { 'No such command exists' }
  end

  class NotBooleanError < Error
    define_method(:message) { 'The specified config param is not a boolean' }
  end

  class NotProcError < Error
    define_method(:message) { 'Autocomplete must be a Proc or an Array' }
  end

  class DuplicateParamError < Error
    define_method(:message) { 'Cannot create two params with the same name' }
  end

  class NoSuchParamError < Error
    define_method(:message) { 'No such param exists' }
  end

  class InvalidParamValueError < Error
    define_method(:message) { 'Param failed to pass validation' }
  end

  class RegisterNilParamError < Error
    define_method(:message) { 'The Param Factory is attempting to register a nil.' }
  end

  class NoSuchOptTypeError < Error
    define_method(:message) { 'The specified opt type was not :boolean or :required' }
  end

  class RedefineOptsError < Error
    define_method(:message) { 'Cannot re-define opts' }
  end

  class NoSuchShellError < Error
    define_method(:message) { 'The shell index does not contain that shell' }
  end

  class NotAShellError < Error
    define_method(:message) { 'Cannot add non-shells to the shell index' }
  end

  class NotAShellFactoryError < Error
    define_method(:message) { 'Cannot add non-shell-factories to the shell factory index' }
  end

  class NotAModuleError < Error
    define_method(:message) { 'Cannot add non-modules to the module index' }
  end

  class NoSuchModuleError < Error
    define_method(:message) { "No such module #{@msg} found." }
  end

  class DuplicateIndexError < Error
    define_method(:message) { 'There is already an object with that name in the index' }
  end

  class TimeoutError < Error
    define_method(:message) { 'Operation timed out.' }
  end
end
