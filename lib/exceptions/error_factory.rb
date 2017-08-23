module Shelldon
  class ErrorFactory
    attr_reader :on_accept_error, :on_reject_error

    def initialize(&block)
      @accept_errors = {}
      @reject_errors = {}
      @default = proc { |e| on_error(e) }
      instance_eval(&block)
    end

    def default(&block)
      @default = block
    end

    def accept(e, &block)
      @accept_errors[e] = (block_given? ? block : nil)
    end

    def reject(e, &block)
      @reject_errors[e] = (block_given? ? block : nil)
    end

    def on_accept(&block)
      @on_accept_error = block
    end

    def on_reject(&block)
      @on_reject_error = block
    end

    def get
      [@accept_errors, @reject_errors]
    end
  end
end
