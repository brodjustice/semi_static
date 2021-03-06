require_dependency "semi_static/application_controller"

module SemiStatic

  class SiteController < ApplicationController

    caches_page :show

    VIEWS = {
      'home' => 'semi_static_home',
      'imprint-credits' => 'semi_static_application',
      'thank_you' => 'semi_static_application'
    }

    def show
      @selection = 'Home'
      params[:content] ||= 'home'
      content = (VIEWS.keys.include?(params[:content]) && params[:content]) || nil
      @tag, @seo = Seo.root(params[:tag_id], I18n.locale, content&.humanize)
      @summaries = true

      # Work out what image (if any) "style" should be applied. Check if PageAttr imageStyle provided
      @entry_image_style = @tag&.get_page_attr('imageStyle')&.to_sym || :summary

      @linked = true

      respond_to do |format|
        if content
          format.html { render content, :layout => VIEWS[params[:content]] }
        else
          raise ActiveRecord::RecordNotFound
        end
      end
    end

    #
    # Special route for webserver SSI. In nGinix this must be enabled
    # with 'ssi on;'. This non-REST route then allows
    # nGinx to pick up the csrf meta tags for cached pages via SSI
    #
    def csrf_meta_tags
      respond_to do |format|
        format.html { render :layout => false }
        format.js
      end
    end

  end
end
