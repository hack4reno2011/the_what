# Capistrano
set :application, "the_what"
set :hostname, "thewhat.co"

# RVM
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "ruby-1.9.3-rc1@#{application}"

# Bundler
require 'bundler/capistrano'

# Servers
role :web, "#{hostname}"
role :app, "#{hostname}"
role :db,  "#{hostname}"

# Server options
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, true
set :deploy_to, "/var/lib/capolite/apps/#{application}"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

# Repo options
set :scm, :git
set :repository, "git@github.com:hack4reno/#{application}.git"
set :branch, "master"

# Tasks
namespace :deploy do
  desc "Fix ownership"
  task :fix_ownership, :roles => :app do
    sudo "chown -R apache:apache #{latest_release}"
    sudo "chown -h apache:apache #{deploy_to}/#{current_dir}"
  end
  desc "Compile assets"
  task :assets, :roles => :app do
    run "cd #{current_path} && #{sudo :as => 'apache'} /usr/local/rvm/bin/rvm #{rvm_ruby_string} exec bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  end
end

namespace :unicorn do
  desc "Start unicorn"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{sudo :as => 'apache'} /usr/local/rvm/bin/rvm #{rvm_ruby_string} exec bundle exec unicorn -E #{rails_env} -c #{current_path}/config/unicorn.rb -D"
  end

  desc "Stop unicorn"
  task :kill, :roles => :app, :except => { :no_release => true } do
    run "#{sudo :as => 'apache'} kill `cat #{unicorn_pid}`"
  end

  desc "Stop unicorn gracefully"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{sudo :as => 'apache'} kill -s QUIT `cat #{unicorn_pid}`"
  end

  desc "Reload unicorn"
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{sudo :as => 'apache'} kill -s USR2 `cat #{unicorn_pid}`"
  end
end

before 'deploy:symlink', 'deploy:assets'
after 'deploy:symlink', 'deploy:fix_ownership'
after 'deploy:start', 'unicorn:start'
after 'deploy:restart', 'unicorn:reload'
after 'deploy:stop', 'unicorn:stop'
