# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shelldon/version'

Gem::Specification.new do |spec|
  spec.name     = 'shelldon'
  spec.version  = Shelldon::VERSION
  spec.authors  = ['Wesley Boynton']
  spec.email    = ['wes@boynton.io']
  spec.homepage = 'https://github.com/wwboynton/shelldon'

  spec.summary     = 'An expressive DSL for building interactive command-line apps'
  spec.description = "Shelldon is an expressive DSL for build interactive command-line apps (REPLs)\
with minimal effort. It supports all kinds of fun features, like config/history management, \
error handling, subcommands, subshells, and more!"
  spec.license = 'MIT'

  # spec.files         = Dir["#{File.dirname(__FILE__)}/**/**/**/**/*"].reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = 'shelldon'
  spec.require_paths = %w(lib bin)

  # spec.add_runtime_dependency 'terminal-table', '~> 1.10'
  # spec.add_runtime_dependency 'rb-readline', '~> 0.5.3'
  spec.add_runtime_dependency 'getopt', '~> 1.4.2'
  # spec.add_runtime_dependency 'byebug', '~> 8.2.1'
  spec.add_runtime_dependency 'fuzzy_match'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.33.0'
  # spec.add_development_dependency 'byebug', '~> 8.2.1'
end
