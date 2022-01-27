# frozen_string_literal: true

require_relative 'lib/thumbor/version.rb'

Gem::Specification.new do |s|
  s.name = 'ruby-thumbor'
  s.version = Thumbor::VERSION

  s.authors = ['Bernardo Heynemann', 'Guilherme Souza']
  s.description = 'ruby-thumbor is the client to the thumbor imaging service (http://github.com/thumbor/thumbor).'
  s.email = ['heynemann@gmail.com', 'guilherme@souza.tech']
  s.license  = "MIT"

  s.files = Dir.glob('lib/**/*.rb')
  s.test_files = Dir.glob('spec/**/*.rb')

  s.homepage = 'http://github.com/thumbor/ruby-thumbor'

  s.extra_rdoc_files = Dir["README.md"]
  s.rdoc_options += [
    "--title", "Ruby-Thumbor",
    "--main", "README.md",
    "--line-numbers",
    "--inline-source",
    "--quiet"
  ]

  s.summary = 'ruby-thumbor is the client to the thumbor imaging service (http://github.com/thumbor/thumbor).'

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/thumbor/ruby-thumbor/issues",
    "documentation_uri" => "https://www.rubydoc.info/gems/ruby-thumbor",
    "homepage_uri"      => s.homepage,
    "source_code_uri"   => "https://github.com/thumbor/ruby-thumbor"
  }

  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.10'

end
