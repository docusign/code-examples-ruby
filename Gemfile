	# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~>3.0.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.4.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4.2'
# Use Puma as the app server
gem 'puma', '~> 4.3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
if RUBY_PLATFORM =~ /mswin/
  gem 'bootsnap', '>= 1.1.0', '< 1.4.2', require: false
else
  gem 'bootsnap', '~> 1.7.3', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.1.1', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '> 3.2.1'
  gem 'web-console', '~> 4.0.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'pry-nav', '~> 0.3.0'
  gem 'pry-rails', '~> 0.3.9'
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.1'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.31.0'
  gem 'selenium-webdriver', '~> 3.142.7'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper', '~> 2.1.1'
end

gem 'docusign_esign', '~> 3.15.0'
gem 'docusign_monitor', '~> 1.0.0'
gem 'docusign_rooms', '~> 1.2.0.rc1'
gem 'docusign_click', '~> 1.0.0'
gem 'docusign_admin', '~> 1.0.0'
gem 'omniauth-oauth2', '~> 1.7.1'
gem 'omniauth-rails_csrf_protection'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2019.3', platforms: %i[mingw mswin x64_mingw jruby]
gem 'wdm', '>= 0.1.0', platforms: %i[mingw mswin x64_mingw]

gem "webrick", "~> 1.7"
