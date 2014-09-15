class SemiStaticInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  SEED_FILE_UNIQUE_ID = 'BL-SemiStatic-ct688G4zQ'
  MOUNT_ROUTE = 'mount SemiStatic::Engine, :at => "/"'
  DEVISE_SECRET_KEY = 'config.secret_key'

  def copy_database_migrations
    directory('../../../../db/migrate', destination_root + '/db/migrate')
  end

  def copy_database_seeds
    seed_id_found = run("grep -w \'#{SEED_FILE_UNIQUE_ID}\' db/seeds.rb >/dev/null")
    if seed_id_found == true
      say '  SemiStatic  seed data seems to have been added already, skiping this bit'
    else
      seed_data = File.read(File.dirname(__FILE__) + '/../../../db/seeds.rb')
      append_to_file('./db/seeds.rb', "\n# Please do not remove, SemiStatic seed code start #{SEED_FILE_UNIQUE_ID}\n")
      append_to_file('./db/seeds.rb', seed_data)
      append_to_file('./db/seeds.rb', "\n# SemiStatic seed code end\n")
      password = SecureRandom.hex(4)
      gsub_file 'db/seeds.rb', /admin-password-to-change/, "#{password}"
      say '  SemiStatic  check \'./db/seeds.rb\' to see the admin password for your site'
    end
  end

  def copy_stylesheets
    say '  SemiStatic  Stylesheets will be copied to your application unless you have them already'
    directory('../../../../app/assets/stylesheets', destination_root + '/app/assets/stylesheets')
  end

  def move_initializer
    say '  SemiStatic  initializer will be moved to your application directory, remember to edit it to suit your needs'
    copy_file './../../../../config/initializers/semi-static.rb', './config/initializers/semi-static.rb'
  end

  def add_engine_to_routes
    routes_found = run("grep -w \'#{MOUNT_ROUTE}\' config/routes.rb >/dev/null")
    if routes_found == true
      say '  SemiStatic  mountable routes already added, skiping this bit'
    else
      say '  SemiStatic  routes will be mounted, adding to config/routes'
      inject_into_file "./config/routes.rb", "\n  " + MOUNT_ROUTE, :after => "Application.routes.draw do"
    end
  end

  def set_devise_token
    engine_path = File.dirname(__FILE__) + '/../../../'
    devise_secret_key_found = run("grep -w \'#{DEVISE_SECRET_KEY}\' #{engine_path + 'config/initializers/devise.rb'} >/dev/null")
    if devise_secret_key_found == true
      say '  SemiStatic  setting devise secret_key'
      new_key = "  config.secret_key = \'#{SecureRandom.hex(64)}\'"
      gsub_file "#{engine_path + 'config/initializers/devise.rb'}", /.*config.secret_key.*$/, "#{new_key}"
    else
      say '  SemiStatic  ERROR cannot find secret ket in the devise initilaizer (devise.rb)'
    end
  end

  def remove_public_index
    remove_file('public/index.html')
  end

  def execute_migrations
    if yes?("Would you like to run the database setup? (y/n):")
      run "rake db:migrate"
      run "rake db:seed"
    end
  end

end
