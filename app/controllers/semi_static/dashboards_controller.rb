require_dependency "semi_static/application_controller"

module SemiStatic
  class DashboardsController < ApplicationController

    layout 'semi_static_dashboards'

    before_filter :authenticate_user!
    # Note: cannot seem to use CanCan if there is no model/class, thus the following fails
    #   load_and_authorize_resource
    # so we do a manual authorization in the show action. However, even then we cannot
    # rasie the exception normally. eg:
    #   raise CanCan::AccessDenied.new("Not authorized!", :show, Dashboard)
    # as there is no Dashboard class
  
    def show
      if params[:role]
        @role = Role.find_by_name(params[:role])
        unless @role && current_user.has_role?(@role.name)
          raise CanCan::AccessDenied.new("Not authorized!", :show, Role)
        end
      else
        @role = current_user.top_role
      end
  
      @selected = 'home'
  
      @instruments = DashboardHelper::INSTRUMENTS[@role.name.to_sym]
      
      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @user }
      end
    end
  end
end
