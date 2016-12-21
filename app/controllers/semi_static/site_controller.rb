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
      content = VIEWS.keys.include?(params[:content]) && params[:content]
      @tag, @seo = Seo.root(params[:tag_id], I18n.locale, content.humanize)
      @summaries = true

      # Some themes have a contact box on the home page
      @contact = Contact.new

      respond_to do |format|
        if content
          format.html { render content, :layout => VIEWS[params[:content]] }
        else
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
