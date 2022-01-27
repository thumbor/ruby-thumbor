# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'thumbor/version'

desc 'Build gem last version'
task :build do
  system 'mkdir -p pkg/gems'
  system 'gem build ruby-thumbor.gemspec'
  system "mv ruby-thumbor-#{Thumbor::VERSION}.gem pkg/"
end

desc 'Build and gem upload'
task release: :build do
  system "gem push pkg/ruby-thumbor-#{Thumbor::VERSION}.gem"
end
