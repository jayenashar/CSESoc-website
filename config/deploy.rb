set :application, "csesoc-django"
set :repository, "git://github.com/UNSW-CSESoc/CSESoc-Django.git" 

set(:user) do
   Capistrano::CLI.ui.ask "Give me a ssh user: "
end

set :scm, :git
set :branch, "master"

set :deploy_to, "~/#{application}"
set :deploy_via, :remote_cache

role :web, "csesoc.unsw.edu.au"     # Your HTTP server, Apache/etc
role :app, "csesoc.unsw.edu.au"     # This may be the same as your `Web` server
role :db,  "csesoc.unsw.edu.au", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # run "#{try_sudo} service apache2 restart"
    # This account does not have root, 
    # so you need to restart apache2 from Root.
  end
end

after "deploy:symlink", "deploy:super_patch"
namespace :deploy do
  desc "Applies the 'super patch'"
  task :super_patch do
    run "cd ~/#{application}/current/csesoc && patch -p0 < ~/super_patch"
  end
end

after "deploy:symlink", "deploy:link_db"
namespace :deploy do
  desc "Links the sqlite database and run syncdb"
  task :link_db do
    run "ln -s ~/db.sqlite3 ~/#{application}/current/csesoc/db.sqlite3"
    
    run "cd && chmod -R g-w ." # Sets everything in ~www's home g-w
    
    # run "cd ~/#{application}/current/csesoc && python manage.py syncdb"
  end
end

