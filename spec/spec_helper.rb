$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

if /^1\.9/ === RUBY_VERSION
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
end

RSpec.configure do |c| 
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
