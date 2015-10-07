# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'zumbaster'
set :repo_url, 'https://github.com/dzhaparoff/zumbaster.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/zumbaster'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, [])
                       .push('config/database.yml', 'config/config.yml', 'config/secrets.yml', 'config/app_environment_variables.rb')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, [])
                      .push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        # execute :rake, "sitemap:generate"
        # execute :ln, "-s #{release_path}/public/sitemaps/sitemap.xml #{release_path}/public/sitemap.xml"
        execute :rake, 'tmp:clear'
        #execute "RAILS_ENV=production bin/delayed_job restart"
      end
    end
  end

  after :finishing, 'deploy:cleanup'

end