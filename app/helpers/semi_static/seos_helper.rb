module SemiStatic
  module SeosHelper
    def seo_title
      @seo ? (@seo.title.blank? ? @title || SemiStatic::Engine.config.site_name : @seo.title) : (@title || SemiStatic::Engine.config.site_name)
    end

    def seo_description
      (@seo && !@seo.description.blank?) ? @seo.description : SemiStatic::Engine.config.site_name
    end

    def seo_keywords
      (@seo && !@seo.keywords.blank?) ? @seo.keywords : t('keywords')
    end
  end
end
