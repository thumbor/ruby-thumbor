source 'https://rubygems.org'

group :development do
    gem 'guard'
    gem 'guard-rspec'
    gem 'rb-fsevent', '~> 0.9.1'
end

group :development, :test do
    gem "simplecov", :platforms => :mri_19
    gem "rspec"
end

group :test do
    gem "json_pure", :platforms => :ruby_18, :require => "json/pure"
end
