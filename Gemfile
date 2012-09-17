source :rubygems

group :development do
    gem "hoe"
    gem "newgem"
    gem "ruby-debug19", :platforms => :mri_19, :require => 'ruby-debug'
end

group :development, :test do
    gem "simplecov", :platforms => :mri_19
    gem "rspec"
end

group :test do
    gem "json_pure", :platforms => :ruby_18, :require => "json/pure"
end
