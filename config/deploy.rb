require File.expand_path('./environment', __dir__)

# config valid only for current version of Capistrano
lock '~> 3'

set :application, 'also'
set :repo_url, 'https://github.com/RISCfuture/also.fm.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/also.fm'

set :rvm_ruby_version, "2.7.0@#{fetch :application}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
       'vendor/bundle', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :bugsnag_api_key, Rails.application.credentials.bugsnag_api_key

# set :nvm_type, :system
# set :nvm_node, 'v9.5.0'
# append :nvm_map_bins, 'yarnpkg', './bin/yarn', 'webpack'
set :default_env,
    'PATH' => '/usr/local/nvm/versions/node/v12.14.1/bin:$PATH'

set :passenger_restart_with_sudo, true
