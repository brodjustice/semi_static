require 'elasticsearch'
require 'elasticsearch/model'
require 'elasticsearch/rails'

module SemiStatic
  class Engine < ::Rails::Engine

    require 'haml'
    require 'jquery-rails'
    require 'jquery-ui-rails'
    require 'actionpack/page_caching'
    require 'kaminari'


    SOCIAL_LINKS = {
      'youtubeChannel' => {:name => 'YouTube', :domain => 'https://www.youtube.com/'},
      'xingID' => {:name => 'Xing', :domain => 'https://www.xing.com/'},
      'googleplusID' => {:name => 'GooglePlus', :domain => 'https://plus.google.com/'},
      'linkedinID' => {:name => 'LinkedIn', :domain => 'http://www.linkedin.com/'},
      'facebookID' => {:name => 'Facebook', :domain => 'https://www.facebook.com/'},
      'instagramID' => {:name => 'Instagram', :domain => 'http://instagram.com/'},
      'kununuID' => {:name => 'Kununu', :domain => 'http://kununu.com/'},
      'twitterID' => {:name => 'Twitter', :domain => 'https://twitter.com/'}
    }

    @@social_links = {}

    def social_links
      @@social_links
    end

    @@layouts = {
      0 => 'application',
      1 => 'home',
      2 => 'full',
      3 => 'embedded_full',
      4 => 'embedded_fonts_full',
      5 => 'jquery'
    }

    def layouts
      @@layouts
    end

    def layouts=(hash)
      @@layouts = hash
    end

    def layout_select(obj)
      'semi_static_' + @@layouts[obj.layout_select || 0].to_s
    end


    #
    # Rails 4/5 sprockets no longer automatically compiles images from the standard Engine asset directories. In 
    # other words the documentation is incorrect when it says "Assets within an engine work in an identical way
    # to a full application..."
    #
    # The issue and the workaround that we use is discussed here:
    #   https://github.com/rails/sprockets/issues/542
    # So we add a 'manifest' file to the asset pipeline (engine_assets.css) which contains link_tree commands
    # to the image and font resources.
    config.assets.precompile << 'engine_assets.css'

    #
    # Now add the semi-static assets to be compiled. Adding here avoids us having to 
    # polute the applications /config/initilaizers/assets.rb
    #
    config.assets.precompile += %w( favicon.ico home.css font.css semi_static_application.css semi_static_full.css semi_static_dashboard.css user_dashboard.css semi-static.js semi_static_application.js semi_static_dashboard.js semi_static_jquery.js home_theme.js theme.js user_dashboard.js bootstrap.js bootstrap-dashboard.js jquerytablesorter.min.js table-dashboard.css )

    initializer :load_environment_config do |app|
      # We need the files in the applications semi-static locales to override the engine if present, so make sure
      # that they are added at the end
      config.i18n.load_path += Dir[Rails.application.config.root.join('config/locales/semi-static', '*.{rb,yml}').to_s]
    end

    isolate_namespace SemiStatic
    initializer "semi_static.assets.precompile" do |app|
      #
      # There is no load path for coffescript like there is for SASS so we can only use the sprokets load path
      # Need to do this here rather than in config.after_initialize as sprokets will by then have frozen the environment
      #
      Rails.application.config.assets.paths << "#{SemiStatic::Engine.root}/app/assets/javascripts/themes/#{SemiStatic::Engine.config.theme}"
      Rails.application.config.assets.paths << "#{Rails.application.root}/app/assets/stylesheets/semi_static/themes/#{SemiStatic::Engine.config.theme}"
      Rails.application.config.assets.paths << "#{SemiStatic::Engine.root}/app/assets/stylesheets/themes/#{SemiStatic::Engine.config.theme}"

      # Add 2 more load paths and make sure that the dashboard main_app path is before semi_static's

      Rails.application.config.assets.paths << "#{Rails.application.root}/app/assets/stylesheets/semi_static"
      Rails.application.config.assets.paths << "#{SemiStatic::Engine.root}/app/assets/stylesheets/semi_static"
    end

    # Extend config class as 'try?' will not work on it
    config.class.class_eval do
      def has?(val)
        self.respond_to?(val) && self.send(val)
      end
    end
  end
end
