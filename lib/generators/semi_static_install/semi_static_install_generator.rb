class SemiStaticInstallGenerator < Rails::Generators::Base
  # TODO - this surely can be improved, I'm not sure I even fully grasp Thor.

  source_root File.expand_path('../templates', __FILE__)

  GEMFILE_UNIQUE_ID = 'BL-SemiStatic-ct688G4zQ'
  MOUNT_ROUTE = 'mount SemiStatic::Engine, :at => "/"'
  DEVISE_SECRET_KEY = 'config.secret_key'
  PRECOMPILE_ASSETS = 'semi_static_application.css semi_static_full.css semi_static_application.js semi_static_dashboard.js home_theme.js theme.js'
  CONFIG_ASSETS_PRECOMPILE = "Rails.application.config.assets.precompile += %w( #{PRECOMPILE_ASSETS} )"
  ASSET_IMAGE_DIRECTORIES = %w(banners x2 flags)
  DEVISE_FOR_GEMFILE = "gem 'devise'\n"
  SITE_HELPER = 'helper SemiStatic::SiteHelper'
  AFTER_SIGN_IN_MODULE = "require 'semi_static/sign_in'\n  include SignIn"

  # Belts and braces: Always run check to see if Device is included and registarable is set, since
  # that will leave you wide open to anybody registering as admin
  def device_auth_check
    registerable_found = run 'grep registerable app/models/*.rb'
    if registerable_found
      say '    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      say "    IMPORTANT WARNING: Found the string 'registerable' one of your models (see results above)."
      say "    This could well be a MAJOR security problem in device that you really must correct." 
      unless yes?("    We do not advise that you ignore this, but if you really know what you are doing, type Y to ignore (Y/N): ")
        exit
      end
    end
  end

  def copy_database_migrations
    directory('../../../../db/migrate', destination_root + '/db/migrate')
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
      inject_into_file "./config/routes.rb", "\n  " + MOUNT_ROUTE, :after => "Rails.application.routes.draw do"
    end
  end

  def application_controller_configuration
    # Make sure that the SemiStatic SiteHelper is available to the application
    site_helper_found = run("grep -w \'#{SITE_HELPER}\' app/controllers/application_controller.rb >/dev/null")
    if site_helper_found == true
      say '  SemiStatic  site helper already added to application_controller, skiping this bit'
    else
      say '  SemiStatic  semi-static site helper is being adding to app/controllers/application_controller'
      inject_into_file "./app/controllers/application_controller.rb", "\n  " + SITE_HELPER, :after => "ActionController::Base"
    end

    # In case there is noen, add a after_sign_in path
    after_sign_in_path_found = run("grep -w \'after_sig_in_path\' app/controllers/application_controller.rb >/dev/null")
    after_sign_in_module_found = run("grep -w \'SignIn\' app/controllers/application_controller.rb >/dev/null")
    if after_sign_in_path_found == true
      say '  SemiStatic  after_sign_in_path already found in application_controller, skiping this bit'
    elsif after_sign_in_module_found == true
      say '  SemiStatic  SignIn module already included in application_controller, skiping this bit'
    else
      say '  SemiStatic  SignIn module is being included in app/controllers/application_controller'
      inject_into_file "./app/controllers/application_controller.rb", "\n  " + AFTER_SIGN_IN_MODULE, :after => "ActionController::Base"
    end

  end

  def remove_public_index
    remove_file('public/index.html')
  end

  # Rather than messing with the application, it should be possible to add this to the
  # precompile list from within engine.rb. However, this fails to work in Rails 3, so
  # leave for now and change with Rails 4
  def config_assets_precompile
    precompile_found = run("grep -w \'#{PRECOMPILE_ASSETS}\' config/initializers/assets.rb >/dev/null")
    if precompile_found == true
      say '  SemiStatic  NOTICE: Assets to precompile seem to already be listed in ./config/initializers/assets.rb'
    else
      inject_into_file "./config/initializers/assets.rb", "\n" + CONFIG_ASSETS_PRECOMPILE, :after => /^*.config.assets.precompile.*$/
    end
  end

  def check_for_auth
    unless (ActiveRecord::Base.connection.table_exists? 'users') || (ActiveRecord::Base.connection.table_exists? 'admins')
      devise_found = run("grep -w \'devise\' Gemfile >/dev/null")
      if devise_found
          say '  SemiStatic  Great, you seem to already have Devise authentication in your app'
      else
        if yes?("  SemiStatic  Cannot find authentication in your app, would you like to add Devise authentication? (Y/N): ")
          add_auth()
        else
          say '  SemiStatic  WARNING: You will need to make sure that you have authentication in your app'
        end
      end
    else
      say '  SemiStatic  WARNING: You seem to already have have authentication in your app. You will need to provide a way for the administrator to navigate to the semi_static_dashboard_path'
    end
  end

  def execute_migrations
    if yes?("  SemiStatic  Would you like to run the database setup? (Y/N):")
      run "rake db:migrate"
      run "rake db:seed"
    end
  end

  def copy_devise_views
    # Always remove the standard Devise _form as it does not have email fields
    remove_file './app/views/admins/_form.html.erb'
    if yes?("  SemiStatic  Would you like to copy the devise views to your application? (Y/N):")
      # Copy view into app as we nearly always customise them
      @admin_model_name ||= 'admin'
      run("rails generate devise:views " + @admin_model_name)
      # Copy the admin form with email fields
      copy_file './../../../../app/views/semi_static/admins/_form.html.haml', './app/views/admins/_form.html.haml'
    end
  end

  private

  def seed_admin
    if yes?("  SemiStatic  Would you like to add devise admin \'#{@admin_model_name}\' account (migration seed data)? (Y/N):")
      admin_email = ask("            email [admin@business-landing.com]:")
      admin_email = "admin@business-landing.com" if admin_email.blank?
      default_admin_password = SecureRandom.hex(4)
      admin_password = ask("            Password [#{default_admin_password}]:")
      admin_password = default_admin_password if admin_password.blank?
      admin_model_classname = @admin_model_name.classify
      seed_code = "\n#{admin_model_classname}.create! do |a|\n" +
        "  a.name = \'semi-static\'\n" +
        "  a.surname = \'admin\'\n" +
        "  a.email = \'#{admin_email}\'\n" +
        "  a.password = \'#{admin_password}\'\n" +
        "  a.password_confirmation = \'#{admin_password}\'\n" +
        "end\n"
      append_file "db/seeds.rb", seed_code
    end
  end

  def add_auth
    inject_into_file "./Gemfile", "\n" + DEVISE_FOR_GEMFILE, :before => "group :development, :test do\n"

    # Have to install the bundle before we can do the devise generation
    run  "bundle install"

    # generate("devise:install")
    run "rails generate devise:install"

    if yes?("  Would you like a simple devise admin model - Type N to for option to use CanCan ? (Y/N):")
      @admin_model_name = ask("  SemiStatic  What would you like the simple devise admin model to be called? [admin]:")
      @admin_model_name = "admin" if @admin_model_name.blank?
      generate(:scaffold, @admin_model_name + " name:string surname:string")

      filter_instruction = "\n  before_filter :authenticate_" + @admin_model_name +'!'
      inject_into_file "app/controllers/#{@admin_model_name.pluralize}_controller.rb", filter_instruction,
        :after => "ApplicationController"
      generate("devise", @admin_model_name)

      # Need to change the admin model to load the correct devise modules:
      #   devise :database_authenticatable, :trackable, :timeoutable, :lockable
      # This is pretty error prone as we don't know what devise will put in by default, but it's important to
      # get rid of the registerable, else you will not be able to add admins and anybody can register
      gsub_file "app/models/#{@admin_model_name}.rb", /^  devise.*$/, "  devise :database_authenticatable, :trackable, :timeoutable, :lockable"
      gsub_file "app/models/#{@admin_model_name}.rb", /:recoverable.*$/, ""
      gsub_file "app/models/#{@admin_model_name}.rb", /:rememberable.*$/, ""
      gsub_file "app/models/#{@admin_model_name}.rb", /:registerable.*$/, ""

      say "  SemiStatic  Have added a default route for devise, you may want to edit config/routes later"
      say "  For the devise admin model (#{@admin_model_name}) you will typically want:"
      say "    Autenticable + Trackable"
      if yes?("  Would you like to edit the devise migration for the admin model? [#{@admin_model_name}] (Y/N):")
        run "vim db/migrate/*add_devise_to_#{@admin_model_name}*"
      end
      seed_admin
    else
      if yes?("  Would you like to install the CanCan gem for complex role management? (Y/N): ")

        @model_name = ask("  What would you like the devise user model to be called? [user]:")
        @model_name = "user" if @model_name.blank?
        generate(:scaffold, @model_name + " name:string surname:string")
        filter_instruction = "\n  before_filter :authenticate_" + @model_name +'!'
        inject_into_file "app/controllers/#{@model_name.pluralize}_controller.rb", filter_instruction,
          :after => "ApplicationController"
        generate("devise", @model_name)
        # Copy view into app as we nearly always customise them
        run("rails generate devise:views users")
        # Configure the initializer to make sure that Devise actually goes there and looks 
        gsub_file "config/initializers/devise.rb", /.*config.scoped_views.*$/, "  config.scoped_views = true"

        say "  SemiStatic  For the devise user model (#{@model_name}) you will typically want:"
        say "                Autenticable + Recoverable + Rememberable + Trackable + Confirmable"
        if yes?("  SemiSTatic  Would you like to edit the devise migration for the user model? [#{@model_name}] (Y/N):")
          run("vim db/migrate/*add_devise_to_#{@model_name}*")
        end

        say "  SemiStatic  You can add a simple devise \'Admin\' model if you have just users and an administrator or"
        say "                if you have more complex roles, like \'moderator\', \'author\', etc. then you"
        say "                decline this and you will be able to install the more flexible the CanCan gem."

        app_roles = ""
        gem "cancan"
        say "    Creating the model and database migration for roles"
        run "rails g model role"
        # Have to update/install the bundle before we can use cancan generations
        run  "bundle install"
        if yes?("  Would you like to add some specific roles now? (Y/N): ")
          while app_roles.blank? do
            app_roles = ask("    Type in your roles seperated by spaces: ")
            say("    You have provided #{app_roles.split(" ").size} roles:")
            app_roles.split(" ").each_with_index {|r, index|
              say("      #{index + 1}) #{r}")
            }
            unless yes?("    Are these roles correct? (Y/N): ")
              app_roles = ""
              next
            end
          end
          say("    Updating and creating the database migration files")
          migration_roles_code = "\n      t.string :name\n"
          migration_file = Dir.glob("db/migrate/*_create_roles.rb")
          inject_into_file migration_file.first, migration_roles_code,
            :after => "create_table :roles do |t|"
          generate(:migration, "create_roles_#{@model_name.downcase.pluralize}")
          migration_file = Dir.glob("db/migrate/*_create_roles_#{@model_name.downcase.pluralize}.rb")
          migration_join_table_code = "\n" +
            "    create_table :roles_#{@model_name.downcase.pluralize}, :id => false do |t|" + "\n" +
            "      t.references :role, :#{@model_name.downcase}" + "\n" +
            '    end'
          inject_into_file  migration_file.first, migration_join_table_code,
            :after => "def up"
          migration_join_table_code = "\n" +
            "    drop_table :roles_#{@model_name.downcase.pluralize}"
          inject_into_file  migration_file.first, migration_join_table_code,
            :after => "def down"
          say("    Updating the user model")
          inject_into_file "app/models/#{@model_name}.rb", "\n  has_and_belongs_to_many :roles",
            :after => "ActiveRecord::Base"
          say("    Updating the role model")
          inject_code = "\n  has_and_belongs_to_many :" + @model_name.tableize + "\nattr_accessible :name\n"
          inject_into_file "app/models/role.rb", inject_code,
            :after => "ActiveRecord::Base"
          unless (admin_role_name = app_roles.split(/\W+/).select{|w| w =~ /admin/i}.first).blank?
            # Create seed code to create admin account
            seed_create_roles_code = "\n"
            app_roles.split(" ").each {|r|
              seed_create_roles_code << "Role.create(:name => \"#{r}\")\n"
            }
            append_file "db/seeds.rb", seed_create_roles_code
            @admin_model_name = @model_name
            seed_admin
            seed_role_code = "\nadmin = #{@model_name.classify}.find_by_surname(\"admin\")\n" +
              "admin_role = Role.find_by_name(\'#{admin_role_name}\')\n" +
              "admin.roles << admin_role\n" +
              "admin.save\n"
            append_file "db/seeds.rb", seed_role_code
          else
            say("      Note: You seem to have no have an admin role and no seed data for the migrations")
          end
        end
        say "    Generating the cancan abilities"
        run "rails g cancan:ability"
        if yes?("  Would you like to edit the cancan abilities model now? (Y/N): ")
          run "vim app/models/ability.rb"
        end
      end
    end
    devise_success = true
  end
end
