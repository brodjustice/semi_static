require_dependency "semi_static/application_controller"

module SemiStatic
  class SystemController < ApplicationController
    # load_and_authorize_resource
  
    CMDS = %w(search_daemon search_reindex expire_cache)
  
    def show
      action, @data, @partial = System.cmd(params[:cmd] || "show" )
      @selected = 'dashboard'
      respond_to do |format|
        format.html { render :action => action }
        format.js { render :action => action }
      end
    end
  
    def update
      if params[:cmd].present? && CMDS.include?(params[:cmd].keys.first)
        action = params[:cmd].keys.first
        @result = System.send(action, params[:cmd][action])
      end
      respond_to do |format|
        format.html { render :template => "system/#{action}" }
        format.js { render :template => "system/#{action}" }
      end
    end
  end
end
