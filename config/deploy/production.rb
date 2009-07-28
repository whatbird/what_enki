#############################################################
#	Application
#############################################################

set :user, 'log55'
set :domain, 'log.the55.net'
set :application, 'loggish'

set :scm_user, user
set :scm_domain, 'the55.net'
set :scm_application, application


# the rest should be good
set :repository,  "git@github.com:whatbird/what_enki.git"
set :deploy_to, "/home/#{user}/#{domain}"
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, false

server domain, :app, :web

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :rails_env, "production"


role :db, domain, :primary => true

#############################################################
#	Passenger
#############################################################

namespace :deploy do

  # desc "Symlink the upload directories"
  # task :before_symlink do
  #   run "mkdir -p #{shared_path}/uploads"
  #   run "ln -s #{shared_path}/uploads #{release_path}/public/uploads"
  # end


  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

end
