source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# FRAMEWORK
gem 'bootsnap'
gem 'rails', '5.2.3'

# CONTROLLERS
gem 'responders'

# MODELS
gem 'email_validation'
gem 'find_or_create_on_scopes'
gem 'pg'
gem 'url_validation'

# ASSETS
gem 'sprockets-rails'
# HTML
gem 'slim-rails'
# CSS
gem 'autoprefixer-rails'
gem 'sass-rails'
# JS
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'uglifier'
# JSON/AJAX
gem 'handlebars_assets'
gem 'jbuilder'

# EXTERNAL
gem 'addressable'
gem 'faraday'
gem 'faraday_middleware'
gem 'nokogiri'

# ERROR TRACKING
gem 'bugsnag'

# OTHER
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development do
  gem 'puma'

  # ERRORS
  gem 'better_errors'
  gem 'binding_of_caller'

  # CHANGE WATCHING
  gem 'listen'
end

group :doc do
  gem 'redcarpet'
  gem 'yard'
end

group :test do
  # SPECS
  gem 'rails-controller-testing'
  gem 'rspec-rails'

  # FACTORIES/DB
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'ffaker'

  # NETWORK
  gem 'fakeweb'

  # TIME
  gem 'timecop'
end

group :production do
  # CACHING
  gem 'redis'

  # CONSOLE
  gem 'irb', require: false
end
