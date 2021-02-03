require "semi_static/engine"
require 'elasticsearch'
require 'paperclip'
require 'truncate_html'

module SemiStatic
  class Railtie < Rails::Railtie

    config.after_initialize do

      # Set up locales from the URL's provided in the config
      SemiStatic::Engine.config.hosts_for_locales = SemiStatic::Engine.config.localeDomains.each_with_object({}) { |(k, v), h| h[k] = v.split('://')[1] }.invert

      def partial_finder
        partials = {}
        if File.directory?(Rails.root.to_s + '/app/views/semi_static/partials')
          Dir.foreach(Rails.root.to_s + '/app/views/semi_static/partials'){|file|
            if file.start_with?('_') && file.include?('.html')
              file = file[1..-1].split('.')[0]
              partials[file.humanize] = "semi_static/partials/#{file}"
            end
          }
        end
        partials
      end

      # There is probably a better way to merge and order the custom partials, this is our best effort.
      SemiStatic::Engine.config.open_partials =
        SemiStatic::Engine.config.open_partials.merge!(partial_finder).sort_by{|name, path| name}.to_h

      # Need to insert load path for themes into the correct place. Can't use prepend_path or append_path
      # as we need it inserted in the correct position in the middle.
      semi_static_root = SemiStatic::Engine.root.to_s
      paths = ActionController::Base.view_paths.collect{|p| p.to_s}
      paths = paths.insert(paths.index(semi_static_root + '/app/views'), semi_static_root + '/app/views/themes/' + SemiStatic::Engine.config.theme)
      ActionController::Base.view_paths = paths

      # The SASS load path for the theme in the config can be added here for Rails 3. But for Rails 4 it's in the assets path (see engine.rb)
      # The path for the views is loaded elsewhere
      # Rails.application.config.sass.load_paths << "#{Rails.application.root}/app/assets/stylesheets/semi_static/themes/#{SemiStatic::Engine.config.theme}"
      # Rails.application.config.sass.load_paths << "#{SemiStatic::Engine.root}/app/assets/stylesheets/themes/#{SemiStatic::Engine.config.theme}"


      # There is no load path for coffescript like there is for SASS so we can only use the sprokets load path
      # So we would normally do this here:
      #   Rails.application.assets.append_path "#{SemiStatic::Engine.root}/app/assets/javascripts/themes/#{SemiStatic::Engine.config.theme}"
      # But here is too late! So this is an initializer in engine.rb

      # Organise the social links
      SemiStatic::Engine::SOCIAL_LINKS.each{|k, v|
        if SemiStatic::Engine.config.respond_to?(k) && SemiStatic::Engine.config.send(k).present?
          SemiStatic::Engine.social_links[k] = v[:domain] + SemiStatic::Engine.config.send(k)
        end
      }

      # Add any app specific layouts
      #
      # Any layout files should be prepended with "semi_static_"
      #
      # The layout is set by an integer which is hard coded as a key to the layout file name. Yuk.
      # To avoid a database migration when adding ability to have custom layouts in main app
      # we generate an integer key to represent the key in the hash.
      if File.directory?(Rails.root.to_s + '/app/views/layouts')
        Dir.foreach(Rails.root.to_s + '/app/views/layouts'){|file|
          if file.start_with?('semi_static_') && file.include?('.html')
            file = file[0..-1].split('.')[0].split('_').last
            SemiStatic::Engine.layouts = SemiStatic::Engine.layouts.merge(file.to_i(36).modulo(10**7) => file)
          end
        }
      end

      # We don't have autoload on the additional paths given to SASS above, so the compromise is to
      # clear the cache on startup, else the changes in the above directories may never be picked up.
      Rails.cache.clear
      system `rake tmp:clear` unless Rails.env.test?

    end
  end
end
