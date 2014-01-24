# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'thumbor/version'

Gem::Specification.new do |s|
  s.name = "ruby-thumbor"
  s.version = Thumbor::VERSION

  s.authors = ["Bernardo Heynemann"]
  s.description = "ruby-thumbor is the client to the thumbor imaging service (http://github.com/globocom/thumbor)."
  s.email = ["heynemann@gmail.com"]
  s.files =  Dir.glob('lib/**/*.rb') << 'README.rdoc'
  s.test_files = Dir.glob('spec/**/*.rb')
  s.homepage = "http://github.com/heynemann/ruby-thumbor"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.summary = "ruby-thumbor is the client to the thumbor imaging service (http://github.com/globocom/thumbor)."


  s.add_development_dependency('rspec')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('rb-fsevent', '~> 0.9.1')
end
