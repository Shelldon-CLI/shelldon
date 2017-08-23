# frozen_string_literal: true

require 'thor'
require 'open-uri'

module Shelldon
  class CLI < Thor
    include Thor::Actions

    desc 'new PROJECT_NAME', 'Sets up ALL THE THINGS needed for your Shelldon project.'

    def new(name)
      name = Thor::Util.snake_case(name)
      system("bundle gem #{name}")
      directory(:project, "#{name}/lib/")
      File.open(name, 'a') { |f| f.write("gem 'shelldon'") }
      system("cd #{name}")
      system('bundle install')
    end
  end
end
