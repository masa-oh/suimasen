# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

set :application, 'suimasen'
set :repo_url, 'git@github.com:masa-oh/suimasen.git'
set :rbenv_ruby, File.read('.ruby-version').strip
set :branch, ENV['BRANCH'] || 'main'

# Nginxの設定ファイル名と置き場所を修正
set :nginx_config_name, "#{fetch(:application)}.conf"
set :nginx_sites_enabled_path, '/etc/nginx/conf.d'

append :linked_files, 'config/database.yml', 'config/master.key', 'config/gcp_key.json'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'node_modules'

#
namespace :deploy do
  # 1. capistranoを実行したマシン側でコンパイルする
  task :compile_assets_locally do
    run_locally do
      with rails_env: fetch(:stage) do
        execute 'bundle exec rails assets:precompile'
      end
    end
  end

  # 2. webpackerとsprocketsで生成したファイルをそれぞれzipする
  task :zip_assets_locally do
    run_locally do
      execute 'tar -zcvf ./tmp/assets.tar.gz ./public/assets 1> /dev/null'
      execute 'tar -zcvf ./tmp/packs.tar.gz ./public/packs 1> /dev/null'
    end
  end

  # 3. zip後のファイルをupload!でWebサーバーに送り込む。
  task :send_assets_zip do
    on roles(:web) do |_host|
      upload!('./tmp/assets.tar.gz', "#{release_path}/public/")
      upload!('./tmp/packs.tar.gz', "#{release_path}/public/")
    end
  end

  # 4. Webサーバー内でunzipする
  task :unzip_assets do
    on roles(:web) do |_host|
      execute "cd #{release_path}; tar -zxvf #{release_path}/public/assets.tar.gz 1> /dev/null"
      execute "cd #{release_path}; tar -zxvf #{release_path}/public/packs.tar.gz 1> /dev/null"
    end
  end
end

# どのタイミングでタスクが呼ばれるのかを記述する。
before 'deploy:updated', 'deploy:compile_assets_locally'
before 'deploy:updated', 'deploy:zip_assets_locally'
before 'deploy:updated', 'deploy:send_assets_zip'
before 'deploy:updated', 'deploy:unzip_assets'