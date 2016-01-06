module Shelldon
  class Confirmation

    def self.ask(*args)
      self.new(*args).ask
    end

    def initialize(msg = 'Confirm? (y/n)',
                   ok = ['y', 'Y', 'yes', 'Yes', 'YES'])
      @msg = msg
      @ok  = ok
    end

    def ask
      puts @msg
      print '> '
      response = $stdin.gets.chomp
      @ok.include?(response) ? true : raise(Shelldon::ConfirmationError)
    end
  end
end