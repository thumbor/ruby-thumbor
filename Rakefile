# frozen_string_literal: true

require 'rspec/core/rake_task'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

task default: :spec
