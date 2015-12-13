# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shelldon/version'

Gem::Specification.new do |spec|
  spec.name          = 'shelldon'
  spec.version       = Shelldon::VERSION
  spec.authors       = ['Wesley Boynton']
  spec.email         = ['wes@boynton.io']

  spec.summary       = 'Shelldon weeeeee'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir["#{File.dirname(__FILE__)}/**/**/**/**/*"].reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = 'shelldon'
  spec.require_paths = %w(lib bin)

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
end
