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
      respond_to do |format|
        format.html { render params[:content], :layout => VIEWS[params[:content]] }
      end
    end
  end
end
