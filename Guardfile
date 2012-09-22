guard 'rspec', :rvm => ['1.8.7@rubythumbor', '1.9.2@rubythumbor', '1.9.3@rubythumbor'] do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

