require_dependency "semi_static/application_controller"

module SemiStatic
  class SystemController < ApplicationController
    before_filter :authenticate_for_semi_static!
  
    CMDS = %w(show search_daemon search_reindex expire_cache clean_up passenger_restart load_url generate_sitemap generate_static_pages partial_description load_search_data)
    SESSION = %w(workspace_tag_id)
  
    def update
      if params[:cmd].present? && CMDS.include?(params[:cmd].keys.first)
        action = params[:cmd].keys.first
        @locale = params[:locale]
        @result = System.send(action, params[:cmd][action], @locale)
      elsif params[:session].present? && SESSION.include?(params[:session].keys.first)
        action = key = params[:session].keys.first
        params[:session][key].blank? ? session.delete(key) : session[key] = params[:session][key]
      end
      respond_to do |format|
        format.html { render :template => "semi_static/system/#{action}", :layout => 'semi_static_dashboards' }
        format.xml do
          stream = render_to_string(:template => "semi_static/system/#{action}" )  
          send_data(stream, :type=>"text/xml", :filename => "sitemap.xml")
        end
        format.js { render :template => "semi_static/system/#{action}" }
      end
    end
  end
end
