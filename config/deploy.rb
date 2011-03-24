set :stages, %w(staging production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

namespace :deploy do
  desc 'after update code'
  task :after_update_code do
    puts " \n\t COPY DB \n"
    run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run 'bundle install'
  end
end

# : : : : : : : : : : : : : : : : : : : : : : : : : : :   db dumping

namespace :db do
  desc 'Dumps the production database to db/production_data.sql on the remote server'
  task :remote_db_dump, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} db:database_dump --trace"
  end

  desc 'Downloads db/production_data.sql from the remote production environment to your local machine'
  task :remote_db_download, :roles => :db, :only => { :primary => true } do
    execute_on_servers(options) do |servers|
      self.sessions[servers.first].sftp.connect do |tsftp|
        tsftp.download!("#{deploy_to}/#{current_dir}/db/production_data.sql", "db/production_data.sql")
      end
    end
  end

  desc 'Cleans up data dump file'
  task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do
    execute_on_servers(options) do |servers|
      self.sessions[servers.first].sftp.connect do |tsftp|
        tsftp.remove! "#{deploy_to}/#{current_dir}/db/production_data.sql"
      end
    end
  end

  desc 'Dumps, downloads and then cleans up the production data dump'
  task :remote_db_runner do
    remote_db_dump
    remote_db_download
    remote_db_cleanup
  end
end


# : : : : : : : : : : : : : : : : : : : : : : : : : : :   COLD DEPLOY!

namespace :deploy do
  task :generate_database_yml, :roles => :app do

    db_params = {
      "adapter"=>"mysql",
      "database"=>"#{application}",
      "username"=>"root",
      "password"=>"",
      "host"=>"localhost",
      "socket"=>""
      }

    db_params.each do |param, default_val|
      set "db_#{param}".to_sym,
        lambda {
        Capistrano::CLI.ui.ask "Enter database #{param}" do |q|
          q.default=default_val
        end
      }
    end


    database_configuration = "#{rails_env}:\n"
    db_params.each do |param, default_val|
      val=self.send("db_#{param}")
      database_configuration<<"  #{param}: #{val}\n"
    end
    
    run "mkdir -p #{deploy_to}/#{shared_dir}/config"
    put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml"
  end
end
