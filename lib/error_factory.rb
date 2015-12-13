module Shelldon
  class ErrorFactory
    def initialize(&block)
      @accept_errors = {}
      @reject_errors  = {}
      @default = Proc.new { |e| on_error(e) }
      self.instance_eval(&block)
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