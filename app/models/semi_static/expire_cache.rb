module SemiStatic
  module ExpireCache
    def expire_site_page_cache
      ExpireCache.expire_site_page_cache
    end
  
    def self.expire_site_page_cache
      # Generally the whole site controller is made up of dynamic elements
      # that really change. This means we can use the page_cache, and just
      # expire the whole lot when a update is made to certains classes.
  
      # Expire the index page, not needed as this is an Engine
      # ActionController::Base::expire_page("/")
  
      # Expire the site_path(:content => 'x') pages.
      # You would expect one of these to work:
      #
      #   ActionController::Base::expire_page(:controller => 'site, :action => 'show')
      #   ActionController::Base::expire_page(app.site_path(:content => 'coaches'))
      #
      # but none of these work. So we have to manually clear out the pages from the
      # public directory ourselves:
      #
  
      I18n.available_locales.each{|l|
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/index.html").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/site").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/references.html").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/references").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/photos.html").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/photos").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/features").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/features.html").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/entries").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/entries.html").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/#{SemiStatic::Engine.config.tag_paths[l]}").to_s)
      }
    end
  end
end
