# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "suimasen"
set :repo_url, "git@github.com:masa-oh/suimasen.git"
set :rbenv_ruby, File.read('.ruby-version').strip
set :branch, ENV['BRANCH'] || "master"

# Nginxの設定ファイル名と置き場所を修正
set :nginx_config_name, "#{fetch(:application)}.conf"
set :nginx_sites_enabled_path, "/etc/nginx/conf.d"

append :linked_files, "config/database.yml", "config/master.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "node_modules"
