require "semi_static/engine"
require "devise"
require 'elasticsearch'
require 'paperclip'
require 'truncate_html'

module SemiStatic
  class Railtie < Rails::Railtie
    config.after_initialize do
      SemiStatic::Engine.config.hosts_for_locales = SemiStatic::Engine.config.localeDomains.each_with_object({}) { |(k, v), h| h[k] = v.split('://')[1] }.invert
    end
  end
end
