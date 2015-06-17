module SemiStatic
  module Pages

    def expire_site_page_cache
      Pages.expire_site_page_cache
    end

    def sitemappable
      self.seo.nil? || (!self.seo.no_index && self.seo.include_in_sitemap)
    end

    def xml_changefreq
      self.seo && SemiStatic::Seo::CHANGE_FREQ_SYMS[self.seo.changefreq] != :unknown && SemiStatic::Seo::CHANGE_FREQ_SYMS[self.seo.changefreq].to_s.downcase
    end

    def xml_priority
      seo ? (seo.priority.to_f/10).to_s : '0.5'
    end

    # This need improving, for example we should go through all the entries
    # with 'home' set and find the latest up date, or wher the 'home'
    # was unset, etc. This is not even considering predefined tags that
    # have been added in the config. Sort of complex so we just return nil for now
    
    def xml_update

      if self.kind_of?(Tag) && self.seo
        (self.updated_at > self.seo.updated_at) ? nil : self.seo.updated_at
      elsif !self.kind_of?(Tag) && self.respond_to?('seo') && self.seo
        (self.updated_at > self.seo.updated_at) ? self.updated_at : self.seo.updated_at
      elsif  !self.kind_of?(Tag)
        self.updated_at
      else
        nil
      end
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
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/documents/index.html").to_s)
        FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/contacts/new.html").to_s)

        # If there are no config.tag_paths don't do this, as the path will resolve to the
        # top level locales cache directory and it will be removed along with links
        # to your assets and system directories
        unless SemiStatic::Engine.config.tag_paths[l.to_s].nil?
          FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/#{SemiStatic::Engine.config.tag_paths[l.to_s]}").to_s)
        end
      }
    end
  end
end
