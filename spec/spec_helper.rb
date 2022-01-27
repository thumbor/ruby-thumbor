# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.single_report_path = 'coverage/lcov.info'
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
)

SimpleCov.start do
  add_filter '/spec/'
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end
