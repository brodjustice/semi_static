require "semi_static/engine"
require "devise"
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
      SemiStatic::Engine.config.open_partials.merge! partial_finder

      # Need to insert load path for themes into the correct place. Can't use prepend_path or append_path
      # as we need it inserted in the correct place.
      semi_static_root = SemiStatic::Engine.root.to_s
      paths = ActionController::Base.view_paths.collect{|p| p.to_s}
      paths = paths.insert(paths.index(semi_static_root + '/app/views'), semi_static_root + '/app/views/themes/' + SemiStatic::Engine.config.theme)
      ActionController::Base.view_paths = paths

      # The SASS load path for the theme in the config is added here. The path for the views is loaded elsewhere
      Rails.application.config.sass.load_paths << "#{Rails.application.root}/app/assets/stylesheets/semi_static/themes/#{SemiStatic::Engine.config.theme}"
      Rails.application.config.sass.load_paths << "#{SemiStatic::Engine.root}/app/assets/stylesheets/themes/#{SemiStatic::Engine.config.theme}"

      # We don't have autoload on the additional paths given to SASS above, so the compromise is to clear the cache on startup, else
      # the changes in the above directories may never be picked up.
      Rails.cache.clear
      system `rake tmp:clear`

    end
  end
end
