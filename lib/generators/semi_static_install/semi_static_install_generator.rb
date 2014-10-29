class SemiStaticInstallGenerator < Rails::Generators::Base
  # TODO - this surely can be improved, I'm not sure I even fully grasp Thor.

  source_root File.expand_path('../templates', __FILE__)

  GEMFILE_UNIQUE_ID = SEED_FILE_UNIQUE_ID = 'BL-SemiStatic-ct688G4zQ'
  MOUNT_ROUTE = 'mount SemiStatic::Engine, :at => "/"'
  DEVISE_SECRET_KEY = 'config.secret_key'
  PRECOMPILE_ASSETS = 'semi_static_application.css semi_static_full.css semi_static_application.js'
  CONFIG_ASSETS_PRECOMPILE = "config.assets.precompile += %w( #{PRECOMPILE_ASSETS} )"
  ASSET_IMAGE_DIRECTORIES = %w(banners x2 flags)

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
    # Because of a wierd sass-rails namespacing problem which is noted here, and elsewhere:
    #   https://github.com/rails/sass-rails/issues/165
    # our engine will not be able to get the correct load paths for our assets in the application
    # unless we take the sass-rails gem out of the assests group in the application Gemfile. So
    # we need to do some fancy editing here:
    gemfile_id_found = run("grep -w \'#{GEMFILE_UNIQUE_ID}\' Gemfile >/dev/null")
    if gemfile_id_found == false
      sassrails = `grep -w \'sass-rails\' Gemfile`
      gsub_file 'Gemfile', /gem \'sass-rails\'.*$/, "# Commented out by SemiStatic generator\n  # #{GEMFILE_UNIQUE_ID} - Please don't remove\n  # #{sassrails}"
      inject_into_file "Gemfile", "\n# Added by SemiStatic for asset namespacing\n" + sassrails + "\n", :before => "group :assets do\n"
    end

    themes = ""
    # Now copy just the variable.css.scss file for each theme to the application
    inside(source_paths.first + '/../../../../app/assets/stylesheets/themes') do
      themes = `ls ../../../../app/assets/stylesheets/themes`
    end

    themes.split.each{|theme|
      empty_directory(destination_root + "/app/assets/stylesheets/semi_static/themes/#{theme}")
      copy_file("../../../../app/assets/stylesheets/themes/#{theme}/variables.css.scss", destination_root + "/app/assets/stylesheets/semi_static/themes/#{theme}/variables.css.scss")
    }
    copy_file('../../../../app/assets/stylesheets/custom.css.scss', destination_root + '/app/assets/stylesheets/semi_static/custom.css.scss')
  end

  def create_asset_image_directories
    ASSET_IMAGE_DIRECTORIES.each{|d|
      empty_directory("app/assets/images/#{d}")
    }
  end

  def copy_custom_partial_example
    say '  SemiStatic  An example custom partial will be created in ./app/views/semi_static/partials'
    directory('../../../../app/views/semi_static/partials', destination_root + '/app/views/semi_static/partials')
  end

  def copy_locales
    say '  SemiStatic  Locales file will be copied into your application unless you have them already'
    directory('../../../../config/locales', destination_root + '/config/locales')
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
      say '  SemiStatic  ERROR cannot find secret key in the devise initilaizer (devise.rb)'
    end
  end

  def remove_public_index
    remove_file('public/index.html')
  end

  def config_assets_precompile
    precompile_found = run("grep -w \'#{PRECOMPILE_ASSETS}\' config/environments/production.rb >/dev/null")
    if precompile_found == true
      say '  SemiStatic  NOTICE: Assets to precompile seem to already be listed in ./config/environments/production.rb'
    else
      inject_into_file "./config/environments/production.rb", "\n  " + CONFIG_ASSETS_PRECOMPILE, :after => /^*.config.assets.precompile.*$/
    end
  end

  def execute_migrations
    if yes?("  SemiStatic  Would you like to run the database setup? (y/n):")
      run "rake db:migrate"
      run "rake db:seed"
    end
  end

end
