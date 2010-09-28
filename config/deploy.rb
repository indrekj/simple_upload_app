# Deploy conf
#
# rake environment vlad:deploy
#
# Run "rake environment vlad:setup" on the first time.
#

require "hoe"

set :user, "ut"
set :repository, "git://github.com/indrekj/simple_upload_app.git"
set :deploy_to, "/home/ut/production"
set :domain, "#{user}@ut.urgas.eu"

namespace :vlad do
  desc "Full deployment cycle"
  task :deploy => [
    "vlad:update",
    #"vlad:migrate",
    "vlad:start_app",
    "vlad:cleanup"
  ]

  Rake.clear_tasks("vlad:start_app")
  remote_task :start_app, :roles => :app do
    run "touch #{latest_release}/tmp/restart.txt"
  end

  Rake.clear_tasks("vlad:update_symlinks")
  remote_task :update_symlinks, :roles => :app do
    puts "Creating symlinks"

    system = "#{deploy_to}/shared/system"
    run "ln -s #{system}/production.sqlite3 #{latest_release}/db/production.sqlite3"
  end

  remote_task :update, :roles => :app do
    Rake::Task["vlad:install_gems"].invoke
  end
 
  remote_task :install_gems, :roles => :app do
    puts "Installing gems"
    run "cd #{latest_release}; bundle install --without development test deployment --deployment"
  end
end
