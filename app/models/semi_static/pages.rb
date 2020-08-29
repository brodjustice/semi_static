module SemiStatic
  module Pages
    def sitemappable
      !self.admin_only &&
      (self.seo.nil? || (!self.seo.no_index && self.seo.include_in_sitemap)) &&
      !(self.kind_of?(Tag) && self.use_entry_as_index.present?) &&
      !(self.kind_of?(Tag) && self.newsletter) &&
      !(self.kind_of?(Entry) && self.link_to_tag) &&
      !(self.kind_of?(Entry) && self.merge_with_previous)
    end

    def xml_changefreq
      self.seo && SemiStatic::Seo::CHANGE_FREQ_SYMS[self.seo.changefreq] != :unknown && SemiStatic::Seo::CHANGE_FREQ_SYMS[self.seo.changefreq].to_s.downcase
    end

    def get_page_attr(k)
      self.page_attrs.find_by_attr_key(k)&.attr_value
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

    # This needs improving, for example we should go through all the entries
    # with 'home' set and find the latest up date, or where the 'home'
    # was unset, etc. This is not even considering predefined tags that
    # have been added in the config. Sort of complex so we just return nil for now
    def xml_update
      if self.kind_of?(Tag) && self.seo && self.predefined_class.nil?
        (self.updated_at > self.seo.updated_at) ? nil : self.seo.updated_at
      elsif !self.kind_of?(Tag) && self.respond_to?('seo') && self.seo
        (self.updated_at > self.seo.updated_at) ? self.updated_at : self.seo.updated_at
      elsif  !self.kind_of?(Tag)
        self.updated_at
      else
        nil
      end
    end
  end
end
