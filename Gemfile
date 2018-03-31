source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# FRAMEWORK
gem 'rails', '5.1.6'

# CONTROLLERS
gem 'responders'

# MODELS
gem 'pg', '< 1.0'
gem 'url_validation'
gem 'email_validation'
gem 'find_or_create_on_scopes'

# ASSETS
gem 'sprockets-rails'
# HTML
gem 'slim-rails'
# CSS
gem 'sass-rails'
gem 'autoprefixer-rails'
# JS
gem 'coffee-rails'
gem 'uglifier'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
# JSON/AJAX
gem 'jbuilder'
gem 'handlebars_assets'

# EXTERNAL
gem 'faraday'
gem 'faraday_middleware'
gem 'nokogiri'
gem 'addressable'

# OTHER
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

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
  gem 'rspec-rails'
  gem 'rails-controller-testing'

  # FACTORIES/DB
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'database_cleaner'

  # NETWORK
  gem 'fakeweb'

  # TIME
  gem 'timecop'
end

group :production do
  # CACHING
  gem 'redis-rails'
  gem 'rack-cache', require: 'rack/cache'
end
