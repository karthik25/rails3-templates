require 'fileutils'
require 'pathname'

@template_root = File.expand_path(File.join(File.dirname(__FILE__)))
@bootstrap     = File.join(@template_root, 'bootstrap')
@assets = File.join(@template_root, 'assets')

paginator_option = ask("\r\n\r\nWhich paginator do you want to use?\r\n\r\n(1) will_paginate\r\n(2) Kaminari\r\nPress Enter to assign default (1)")
bootstrap_option = ask("\r\n\r\nWhat bootstrap/bootswatch theme do you want to use?\r\n\r\n(1) deault bootstrap\r\n(2) Amelia\r\n(3) Cosmo\r\n(4) Journal\r\nPress Enter to assign default (1)")

gem 'rspec-rails', '2.9.0', :group => [:development,:test]
gem 'guard-rspec', '0.5.5', :group => [:development,:test]

gem 'capybara', '1.1.2', :group => :test
gem 'launchy', :group => :test
gem 'factory_girl_rails', '4.1.0', :group => :test

gem 'pg', '0.15.1', :group => :production
gem 'rails_12factor', '0.0.2', :group => :production

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '3.0.1'

if paginator_option == "1"
	gem 'will_paginate', '3.0.3'
else
	gem 'kaminari'
end

run "bundle install"

remove_file "public/index.html"
remove_file "public/images/rails.png"

def process_dir(base_dir, dir_cmd)
	dir = File.join(base_dir, dir_cmd)
	files = Dir[ File.join(dir, '**', '*') ].reject { |p| File.directory? p }
end

files = process_dir(@bootstrap, "js")
files.each do |file|
	FileUtils.cp(file, "vendor/assets/javascripts/#{Pathname.new(file).basename}")
end

FileUtils.mkdir_p("vendor/assets/fonts")
files = process_dir(@bootstrap, "fonts")
files.each do |file|
	FileUtils.cp(file, "vendor/assets/fonts/#{Pathname.new(file).basename}")
end

files = process_dir(@bootstrap, "#{bootstrap_option}_css")
files.each do |file|
	FileUtils.cp(file, "vendor/assets/stylesheets/#{Pathname.new(file).basename}")
end

files = process_dir(@assets, "javascripts")
files.each do |file|
	FileUtils.cp(file, "app/assets/javascripts/#{Pathname.new(file).basename}")
end

files = process_dir(@assets, "stylesheets")
files.each do |file|
	FileUtils.cp(file, "app/assets/stylesheets/#{Pathname.new(file).basename}")
end

files = process_dir(@template_root, "layouts")
files.each do |file|
	FileUtils.cp(file, "app/views/layouts/#{Pathname.new(file).basename}")
end

inject_into_file 'config/application.rb', after: "config.assets.version = '1.0'\n" do <<-'RUBY'
  config.assets.paths << "#{Rails}/vendor/assets/fonts"
RUBY
end
