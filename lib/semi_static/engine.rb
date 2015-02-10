require 'elasticsearch'
require 'elasticsearch/model'
require 'elasticsearch/rails'

module SemiStatic
  class Engine < ::Rails::Engine
    require 'haml'
    require 'jquery-ui-rails'

    isolate_namespace SemiStatic
    initializer "semi_static.assets.precompile" do |app|
      # There is no load path for coffescript like there is for SASS so we can only use the sprokets load path
      # Neeed to do this here rather than in config.after_initialize' as sprokets will by then have frozen the environment
      Rails.application.assets.append_path "#{SemiStatic::Engine.root}/app/assets/javascripts/themes/#{SemiStatic::Engine.config.theme}"
    end
  end
end
