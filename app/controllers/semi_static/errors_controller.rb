require_dependency "semi_static/application_controller"

module SemiStatic
  class ErrorsController < ApplicationController
    def show
      render :layout => 'semi_static_application', status_code.to_s, :status => status_code
    end

    protected
 
    def status_code
      params[:code] || 500
    end
  end
end
