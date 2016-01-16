require 'elasticsearch'
require 'elasticsearch/model'
require 'elasticsearch/rails'

module SemiStatic
  class Engine < ::Rails::Engine
    require 'haml'
    require 'jquery-ui-rails'

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

    initializer :load_environment_config do |app|
      # We need the files in the applications semi-static locales to override the engine if present, so make sure
      # that they are added at the end
      config.i18n.load_path += Dir[Rails.application.config.root.join('config/locales/semi-static', '*.{rb,yml}').to_s]
    end

    isolate_namespace SemiStatic
    initializer "semi_static.assets.precompile" do |app|
      # There is no load path for coffescript like there is for SASS so we can only use the sprokets load path
      # Need to do this here rather than in config.after_initialize' as sprokets will by then have frozen the environment
      Rails.application.assets.append_path "#{SemiStatic::Engine.root}/app/assets/javascripts/themes/#{SemiStatic::Engine.config.theme}"
    end

    # Extend config class as 'try?' will not work on it
    config.class.class_eval do
      def has?(val)
        self.respond_to?(val) && self.send(val)
      end
    end
  end
end
