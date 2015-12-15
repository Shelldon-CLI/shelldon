module Shelldon
  class ErrorFactory
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

    def get
      [@accept_errors, @reject_errors]
    end
  end
end
