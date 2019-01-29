require 'simplecov'
begin
  require 'coveralls'
rescue LoadError
  puts 'Running on Jruby'
end

Coveralls.wear! if defined? Coveralls

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
