require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/ruby-thumbor'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'ruby-thumbor' do
  self.developer 'Bernardo Heynemann', 'heynemann@gmail.com'
  self.post_install_message = 'PostInstall.txt'
  self.rubyforge_name       = 'ruby-thumbor'
   self.extra_deps         = [['ruby-aes','>= 1.1']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

