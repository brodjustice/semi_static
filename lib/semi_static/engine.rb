require 'elasticsearch'
require 'elasticsearch/model'
require 'elasticsearch/rails'

module SemiStatic
  class Engine < ::Rails::Engine
    require 'haml'
    require 'jquery-ui-rails'
    require 'actionpack/page_caching'
    require 'protected_attributes'


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

    initializer :load_environment_config do |app|
      # We need the files in the applications semi-static locales to override the engine if present, so make sure
      # that they are added at the end
      config.i18n.load_path += Dir[Rails.application.config.root.join('config/locales/semi-static', '*.{rb,yml}').to_s]
    end

    isolate_namespace SemiStatic
    initializer "semi_static.assets.precompile" do |app|
      # There is no load path for coffescript like there is for SASS so we can only use the sprokets load path
      # Need to do this here rather than in config.after_initialize' as sprokets will by then have frozen the environment
      #
      # Note: In Rails 3 this was  Rails.application.assets.append_path ...
      #
      Rails.application.config.assets.paths << "#{SemiStatic::Engine.root}/app/assets/javascripts/themes/#{SemiStatic::Engine.config.theme}"
      Rails.application.config.assets.paths << "#{Rails.application.root}/app/assets/stylesheets/semi_static/themes/#{SemiStatic::Engine.config.theme}"
      Rails.application.config.assets.paths << "#{SemiStatic::Engine.root}/app/assets/stylesheets/themes/#{SemiStatic::Engine.config.theme}"
    end

    # Extend config class as 'try?' will not work on it
    config.class.class_eval do
      def has?(val)
        self.respond_to?(val) && self.send(val)
      end
    end
  end
end
