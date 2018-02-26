source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'therubyracer',  platforms: :ruby
#gem 'hydra', '7.1.0'
gem 'active-fedora', '7.1.2'
gem 'blacklight', path: "vendor/blacklight"

gem 'nokogiri', '~> 1.6.0'
gem 'nom-xml', '~> 0.5.1'
gem 'om', '~> 3.1.0'
gem 'rubydora', '~> 1.8.0'
gem 'solrizer', '~> 3.3.0'
gem 'rails_autolink'
gem 'high_voltage', '~> 2.2.1'
gem 'will_paginate', '~> 3.0.6'

gem "resque"
gem "resque-pool"

gem 'bootstrap-sass', '~> 3.3.4.1'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'oai', github: 'code4lib/ruby-oai', branch: 'master'
gem 'libxml-ruby'
gem 'config_for'

gem "devise"
gem "devise-guests", "~> 0.3"
gem 'yaml_db'

group :development do
  gem "foreman"
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails", "~> 4.4.1"
  gem "jettywrapper"
  gem "byebug"
  gem "pry-rails"
  gem "guard-rspec"
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov', :require => false
  gem 'resque_spec'
end
