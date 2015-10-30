require_dependency "semi_static/application_controller"

module SemiStatic
  class SystemController < ApplicationController
    before_filter :authenticate_for_semi_static!
  
    CMDS = %w(search_daemon search_reindex expire_cache clean_up passenger_restart generate_sitemap partial_description)
  
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
        @locale = params[:locale]
        @result = System.send(action, params[:cmd][action], @locale)
      end
      respond_to do |format|
        format.html { render :template => "semi_static/system/#{action}" }
        # format.xml { render :template => "semi_static/system/#{action}", :layout => false, :as => 'sitemap.xml' }
        format.xml do
          stream = render_to_string(:template => "semi_static/system/#{action}" )  
          send_data(stream, :type=>"text/xml",:filename => "sitemap.xml")
        end
        format.js { render :template => "semi_static/system/#{action}" }
      end
    end
  end
end
