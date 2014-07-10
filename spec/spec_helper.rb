require 'simplecov'

SimpleCov.start do
add_filter '/spec/'
end


RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
  c.expect_with :rspec do |config|
    config.syntax = [:should, :expect]
  end
end
