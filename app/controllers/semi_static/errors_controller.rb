require_dependency "semi_static/application_controller"

module SemiStatic
  class ErrorsController < ApplicationController
    def show
      @status_code = params[:code] || 500
      render :layout => 'semi_static_application', :status => @status_code
    end
  end
end
