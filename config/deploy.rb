# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, "discourse-infra"
set :repo_url, "git@github.com:RubyData/discourse.ruby-data.org.git"
set :branch, ENV['branch'] || 'master'
set :deploy_to, "/home/discourse/discourse-infra"
set :pty, true
