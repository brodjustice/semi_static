require_dependency "semi_static/application_controller"

module SemiStatic

  class SiteController < ApplicationController

    # include Rails::ApplicationHelper

    caches_page :show

    VIEWS = {
      'home' => 'semi_static_home',
      'imprint-credits' => 'semi_static_application',
      'thank_you' => 'semi_static_application'
    }

    def show
      @selection = 'Home'
      @tag, @seo = Seo.root(params[:tag_id], I18n.locale)
      @contact = Contact.new
      respond_to do |format|
        format.html { render params[:content], :layout => VIEWS[params[:content]] }
      end
    end
  end
end
