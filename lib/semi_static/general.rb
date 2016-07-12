module General
  LAYOUTS = {
    0 => 'application',
    1 => 'home',
    2 => 'full', 
    3 => 'embedded_full',
    4 => 'embedded_fonts_full',
  }

  def layout_select(obj)
    'semi_static_' + LAYOUTS[obj.layout_select || 0]
  end

  CACHED = ["index.html", "index.html.gz", "news.html", "news.html.gz", "site", "references.html", "references.html.gz", "references", "photos.html", "photos.html.gz", "photos", "features", "features.html", "features.html.gz", "entries", "entries.html", "entries.html.gz", "documents/index.html", "documents/index.html.gz", "contacts/new.html", "contacts/new.html.gz"]

  def expire_page_cache(obj=nil)
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
    unless (obj.kind_of?(SemiStatic::Tag) || obj.kind_of?(SemiStatic::Entry)) && obj.tag.newsletter.present?
      if session[:workspace_tag_id] && obj.kind_of?(SemiStatic::Entry) && obj.tag_id == session[:workspace_tag_id].to_i
        # This was called from an Entry when the session workspace_tag_id matches the entry Tag. In this case
        # we only delete the entry from the cache, not the whole cache.

        # Is this a merged entry?
        obj.merge_with_previous && (obj = obj.merged_main_entry)
        FileUtils.rm_f((Rails.root.to_s + "/public/#{obj.locale.to_s}/#{obj.to_param}").to_s)
      else
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
    true
  end
end
