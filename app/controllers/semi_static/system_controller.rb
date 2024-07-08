require_dependency "semi_static/application_controller"

module SemiStatic
  class SystemController < ApplicationController
    require 'semi_static/general'
    include General

    include SemiStatic::SiteHelper

    before_action :authenticate_for_semi_static!

    UPDATE_CMDS = %w(show search_reindex expire_page_cache clean_up
      passenger_restart load_url generate_sitemap_options
      generate_sitemap generate_static_pages partial_description
    )
    SHOW_CMDS = %w(custom_pages)
    SESSION = %w(workspace_tag_id)

    def show
      if params[:cmd].present? && SHOW_CMDS.include?(params[:cmd])
        @result = send(params[:cmd])
        template = params[:cmd]
      else
        template = 'unknown_cmd'
      end
      respond_to do |format|
        format.html {
          render :template => "semi_static/system/#{template}", :layout => 'semi_static_dashboards'
        }
      end
    end

    def update
      if params[:cmd].present? && UPDATE_CMDS.include?(params[:cmd].keys.first)
        action = params[:cmd].keys.first
        @locale = params[:locale]

        # TODO: All these cmds to be moved from system model to semi_static/general lib. But in the meantime
        # we have this kludge to see if the model still has the fuctionality
        if System.respond_to?(action)
          @result = System.send(action, params[:cmd][action], @locale)
        else
          @result = send(action, params[:cmd][action], @locale)
        end
      elsif params[:session].present? && SESSION.include?(params[:session].keys.first)
        action = key = params[:session].keys.first
        params[:session][key].blank? ? session.delete(key) : session[key] = params[:session][key]
      end
      respond_to do |format|
        format.html {
          render :template => "semi_static/system/#{action}", :layout => 'semi_static_dashboards'
        }
        format.xml do
          stream = render_to_string(:formats => [:xml], :handler => :builder, :template => "semi_static/system/#{action}" )
          send_data(stream, :type=>"text/xml", :filename => "sitemap.xml")
        end
        format.js {
          (action == 'generate_sitemap') &&
            SemiStatic::Engine.config.has?('sitemap').present? &&
            write_sitemap(@locale)
          render :template => "semi_static/system/#{action}", :formats => [:js]
        }
      end
    end
  end
end
