module SemiStatic
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "This guides you through the creation of all the files needed by semi-static"
    
      #
      # Normally we would keep out files to copy in to app in the templates folder:
      #   source_root File.expand_path('../templates', __FILE__)
      # But we are copying assets from the semi_static app so that they can then be
      # overritten by the app developer, so we make the soure_root the top of
      # our gem/engine folder
      #
      source_root File.expand_path('../../../..', __FILE__)
    
      MOUNT_ROUTE = 'mount SemiStatic::Engine, :at => "/"'
      DEVISE_SECRET_KEY = 'config.secret_key'
      ASSET_IMAGE_DIRECTORIES = %w(banners x2 flags)
      SITE_HELPER = 'helper SemiStatic::SiteHelper'
      AFTER_SIGN_IN_MODULE = "require 'semi_static/sign_in'\n  include SignIn"
    
    
      def copy_database_migrations
        say '  SemiStatic  Copying semi_static database migrations to local app'
        #
        # Would like to do this:
        #   rake semi_static:install:migrations
        # but the namespacing of this generator stops this
        #
        directory('db/migrate', destination_root + '/db/migrate')
      end

      def copy_stylesheets
        themes = ""

        # Get the names of all the themes
        inside(source_paths.first + '/app/assets/stylesheets/themes') do
          themes = `ls`
        end

        themes.split.each{|theme|
          empty_directory(destination_root + "/app/assets/stylesheets/semi_static/themes/#{theme}")

          # Now copy just the variable.css.scss file for each theme to the application
          copy_file("./app/assets/stylesheets/themes/#{theme}/variables.scss",
            destination_root + "/app/assets/stylesheets/semi_static/themes/#{theme}/variables.scss")
        }
        copy_file('./app/assets/stylesheets/custom.scss', destination_root + '/app/assets/stylesheets/semi_static/custom.scss')
      end
    
      def create_asset_image_directories
        ASSET_IMAGE_DIRECTORIES.each{|d|
          empty_directory("app/assets/images/#{d}")
        }
      end
    
      def copy_custom_partial_example
        say '  SemiStatic  Example custom partials will be created in ./app/views/semi_static/partials'
        directory('./app/views/semi_static/partials', destination_root + '/app/views/semi_static/partials')
      end
    
      def copy_locales
        say '  SemiStatic  Locales file will be copied into your application unless you have them already'
        directory('./config/locales', destination_root + '/config/locales')
      end
    
      def move_initializer
        say '  SemiStatic  initializer will be moved to your application directory, remember to edit it to suit your needs'
        copy_file './config/initializers/semi-static.rb', './config/initializers/semi-static.rb'
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
    
        # In case there is none, add a after_sign_in path
        after_sign_in_path_found = run("grep -w \'after_sign_in_path\' app/controllers/application_controller.rb >/dev/null")
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

      # Belts and braces: Always run check to see if Device is included and registarable is set, since
      # that will leave you wide open to anybody registering as admin
      def device_auth_check
        registerable_found = run 'grep registerable app/models/*.rb'
        if registerable_found
          say '    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
          say "    IMPORTANT WARNING: Found the string 'registerable' in one of your models (see results above)."
          say "    This could well be a MAJOR security problem in devise that you really must correct." 
          unless yes?("    We do not advise that you ignore this, but if you really know what you are doing, type Y to ignore (Y/N): ")
            exit
          end
        end
      end
    
      def execute_migrations
        if yes?("  SemiStatic  Would you like to run the database setup? (Y/N):")
          rake "db:migrate"
          rake "db:seed"
        end
      end
    
      def copy_devise_views
        # Always remove the standard Devise _form as it does not have email fields
        remove_file 'app/views/admins/_form.html.erb'
        if yes?("  SemiStatic  Would you like to copy the devise views to your application? (Y/N):")
          # Copy view into app as the devloper nearly always customises them
          @admin_model_name ||= 'admin'
          run("rails generate devise:views " + @admin_model_name)

          # Copy the admin form with email fields
          copy_file './app/views/semi_static/admins/_form.html.haml', "./app/views/#{@admin_model_name.pluralize}/_form.html.haml"
        end
      end

      def installation_complete
        say "  SemiStatic  Installation complete."
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
        gem "devise"
        run "bundle install"

        #
        # As is so often the case the Spring Gem can totally screw things up, it's hateful. So
        # we first make sure it has been stopped before we run the generator
        #
        run "spring stop"        
        generate "devise:install"
    
        @admin_model_name = ask("  SemiStatic  What would you like the simple devise admin model to be called? [admin]:")
        @admin_model_name = "admin" if @admin_model_name.blank?
        generate(:scaffold, @admin_model_name + " name:string surname:string password:string password_confirmation:string")
    
        before_action_instruction = "\n  before_action :authenticate_" + @admin_model_name +'!'
        inject_into_file "app/controllers/#{@admin_model_name.pluralize}_controller.rb", before_action_instruction,
          :after => "ApplicationController"
        generate("devise", @admin_model_name)
    
        # Need to change the admin model to load the correct devise modules:
        #   devise :database_authenticatable, :trackable, :timeoutable, :lockable
        # This is pretty error prone as we don't know what devise will put in by default, but it's important to
        # get rid of the registerable, else you will not be able to add admins and anybody can register
        gsub_file "app/models/#{@admin_model_name}.rb", /^  devise.*$/, "  devise :database_authenticatable"
        gsub_file "app/models/#{@admin_model_name}.rb", /^    .*:recoverable.*$/, ""
        gsub_file "app/models/#{@admin_model_name}.rb", /^    .*:rememberable.*$/, ""
        gsub_file "app/models/#{@admin_model_name}.rb", /^    .*:registerable.*$/, ""
        gsub_file "app/models/#{@admin_model_name}.rb", /^    .*:trackable.*$/, ""
        gsub_file "app/models/#{@admin_model_name}.rb", /^    .*:timeoutable.*$/, ""
        gsub_file "app/models/#{@admin_model_name}.rb", /^    .*:lockable.*$/, ""
    
        say "  SemiStatic  Have added a default route for devise, you may want to edit config/routes later"
        say "              For the devise admin model (#{@admin_model_name}) you will typically want:"
        say "                Autenticable + Trackable + Lockable"
        say "              This generator will only include Authenticable, so if you want to add other methods then you"
        say "              will need to edit the migration and the model in the next steps, adding the methods you want."
        if yes?("  Would you like to edit both the devise migration and the model? [#{@admin_model_name}] (Y/N):")
          run "vim db/migrate/*add_devise_to_#{@admin_model_name}*"
          run "vim app/models/#{@admin_model_name}.rb"
        end
        seed_admin

        devise_success = true
      end
    end
  end
end
