module SemiStatic
  class ApplicationController < ActionController::Base

    # Uncomment the following if using CanCan
    # require 'semi_static/can_can_rescue'
    # include CanCanRescue

    before_filter :set_locale

    layout 'semi_static_application'

    def semi_static_admin?
      ((defined? current_admin) && current_admin) || ((defined? current_user) && current_user.respond_to?('admin?') && current_user.admin?)
    end

    def semi_static_current_user
      if defined?(User)
        current_user
      else
        current_admin
      end
    end

    def authenticate_for_semi_static!
      if defined?(CanCan)
        #
        # Not worth checking the CanCan abilities, but if you did it would be like:
        #
        # authorize! params[:action].to_sym, params[:controller].classify
        #
        # But since the ability to access anything in semi_static implies the ability
        # to access all of semi_static, we can just check for access to SemiStatic::Entry,
        # else you have to add the entire model list to the CanCan ability.rb
        authorize! :index, SemiStatic::Entry
      else
        authenticate_admin!
      end
    end

    # Not found ids and slugs are really 404 not 500
    rescue_from ActiveRecord::RecordNotFound do |e|
      @status_code = 404
      @exception = e
      @url = url_for(params)
      render :layout => 'semi_static_application', :template => 'semi_static/errors/show', :status => @status_code
    end

    rescue_from Elasticsearch::Transport::Transport::Errors::NotFound do |e|
      @status_code = 404
      @exception = e
      @url = url_for(params)
      render :layout => 'semi_static_application', :template => 'semi_static/errors/no_index', :status => @status_code
    end

    def extract_locale_from_tld
      # Also it's up to you to make sure that the locale is actually available,
      # though I guess it could be done with something like this:
      #
      # I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : 'de'
      #
      # You also need to consider the page caching. You will need different public 
      # directories to store the page caches for each language, so you will have
      # to adjust your webserver to make this happen.
      SemiStatic::Engine.config.hosts_for_locales[request.host] || SemiStatic::Engine.config.default_locale
    end
  
    def set_locale
      if I18n.locale != (I18n.locale = session[:locale] = extract_locale_from_tld)
        Rails.application.reload_routes!
      end
    end

    # We overwrite the standard page_cache_path method to make it depend on the locale
    def self.page_cache_path(path, extension = nil)
      page_cache_directory.to_s + '/' + I18n.locale.to_s + page_cache_file(path, extension)
    end
  end
end
