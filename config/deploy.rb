# Deploy conf
#
# rake vlad:deploy
#
# Run "rake vlad:setup" on the first time.
#

require "hoe"
require "bundler/vlad"

set :user, "ut"
set :repository, "git://github.com/indrekj/simple_upload_app.git"
set :deploy_to, "/home/ut/production"
set :domain, "#{user}@ut.urgas.eu"

namespace :vlad do
  desc "Full deployment cycle"
  task :deploy => [
    "vlad:update",
    "vlad:create_symlinks",
    "vlad:bundle:install",
    "vlad:migrate",
    "vlad:start_app",
    "vlad:cleanup"
  ]

  Rake.clear_tasks("vlad:start_app")
  remote_task :start_app, :roles => :app do
    run "touch #{latest_release}/tmp/restart.txt"
  end

  desc "Creates our custom symlinks"
  remote_task :create_symlinks, :roles => :app do
    puts "Creating symlinks"

    shared = "#{deploy_to}/shared"
    run "ln -s #{shared}/database.yml #{latest_release}/config/database.yml"
    run "ln -s #{shared}/password.yml #{latest_release}/config/password.yml"
  end
end
