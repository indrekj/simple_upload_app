set :application, 'webct'
set :repository,  'git@github.com:innu/simple_upload_app.git'
set :domain,      ''
set :deploy_to,   "/var/www/#{application}"

set :scm, :git
set :deploy_via, :remote_cache
set :branch, 'master'

set :use_sudo, false
set :ssh_options, {:forward_agent => true}
set :user, 'root'

set :runner, nil
set :spinner, nil

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc 'Migrate the database'
  task :migrate, :roles => :db do
    #run "cd #{release_path}; rake db:migrate MERB_ENV=production --trace --verbose"
  end

  desc 'Create symlinks'
  task :symlink_shared do
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
  end

  desc "Start the application servers."
  task :start do
    run "cd #{release_path}; merb -e production -d"
  end

  desc 'Stop the application servers.'
  task :stop do
    run 'killall merb'
  end 

  desc "Restarts your application."
  task :restart do
    run 'killall merb'
    run "cd #{release_path}; merb -e production -d"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
