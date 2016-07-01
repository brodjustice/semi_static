module SemiStatic
  module Pages
    def expire_site_page_cache
      Pages.expire_site_page_cache(self)
    end

    def sitemappable
      !self.admin_only &&
      (self.seo.nil? || (!self.seo.no_index && self.seo.include_in_sitemap)) &&
      !(self.kind_of?(Tag) && self.use_entry_as_index.present?)
    end

    def xml_changefreq
      self.seo && SemiStatic::Seo::CHANGE_FREQ_SYMS[self.seo.changefreq] != :unknown && SemiStatic::Seo::CHANGE_FREQ_SYMS[self.seo.changefreq].to_s.downcase
    end

    def get_page_attr(k)
      self.page_attrs.find_by_attr_key(k) && self.page_attrs.find_by_attr_key(k).attr_value
    end

    # Get a link to the equivalent alternate page in the given locale. If root is set and no alternate page is found
    # then just link to the home page (root) of the alternate website
    def hreflang_link(locale, root=false)
      link = nil
      if self.seo && !self.seo.hreflangs.empty?
        link = self.seo.hreflangs.find_by_locale(locale) && self.seo.hreflangs.find_by_locale(locale).href
      end
      if link.nil? && root
        link = SemiStatic::Engine.config.localeDomains.select{|k, v| k == locale}[locale]
      end
      link
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

    CACHED = ["index.html", "index.html.gz", "news.html", "news.html.gz", "site", "references.html", "references.html.gz", "references", "photos.html", "photos.html.gz", "photos", "features", "features.html", "features.html.gz", "entries", "entries.html", "entries.html.gz", "documents/index.html", "documents/index.html.gz", "contacts/new.html", "contacts/new.html.gz"]

    def self.expire_site_page_cache(obj=nil)
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

      # If this is a newsletter update, we don't need to expire the cache
      unless (obj.kind_of?(Tag) || obj.kind_of?(Entry)) && obj.tag.newsletter.present?
        # If this is an object with a locale, only expire the cache for tha locale
        locales = (obj.nil? || !obj.respond_to?('locale')) ? I18n.available_locales : [obj.locale]
        locales.each{|l|
          CACHED.each{|c|
            FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/#{c}").to_s)
          }
          # Also delete any context URL tags
          SemiStatic::Tag.with_context_urls.collect{|t| t.name}.each{|tn|
            FileUtils.rm_rf((Rails.root.to_s + "/public/#{l.to_s}/#{tn.parameterize}").to_s)
          }
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
end
