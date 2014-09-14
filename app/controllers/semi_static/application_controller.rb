module SemiStatic
  class ApplicationController < ActionController::Base

    require 'cancan'

    before_filter :set_locale

    layout 'semi_static_application'
  
    # CanCan exception is AccessDenied in 1.6.x, but in the 2.0-alpha gem
    # has been changed as below. The git master changes it back again so watch out.
    # rescue_from CanCan::Unauthorized do |exception|
    rescue_from CanCan::AccessDenied do |exception|
      # Devise will store our intended url in session[:user_return_to]
      # in the case that we were not signed in or were trying to
      # access something we were not authorised for.  But now Cancan
      # will have already overwritten session[:user_return_to]
      # so we need to save it in different session parameter:
      session[:user_intended_url] = url_for(params)
      @em = exception.message + " Action: " + exception.action.to_s
      if exception.subject
        @em += ", object class: " + exception.subject.class.to_s + ", id: " + exception.subject.object_id.to_s
      end
      respond_to do |format|
        if current_user
          format.html { redirect_to site_path(:access_denied), :alert => @em }
          format.js { render 'site/access_denied', :alert => @em }
        else
          format.html { redirect_to new_user_session_path }
          format.js { render 'site/access_denied', :alert => @em }
        end
      end
    end
  
    def after_sign_in_path_for(resource)
      # Normally, we would do the follow in devise, but see above for the cancan
      # interaction:
      if session[:user_intended_url].nil?
        url = semi_static.dashboard_path(resource.top_role.name)
      else
        url = session[:user_intended_url].to_s
        session[:user_intended_url] = nil
      end
      url
    end
  
    def extract_locale_from_tld
      # Also it's up to you to make sure that the locale is actually available,
      # though I guess it could be done with something like this:
      #
      # I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : 'de'
      #
      # You also need to consider the page caching. You will need different public 
      # directories to store the page caches for each language, so youu will have
      # to adjust your webserver to make this happen.
      SemiStatic::Engine.config.hosts_for_locales[request.host] || 'en'
    end
  
    def set_locale
      # I18n.locale = (session[:locale] = params[:locale] || session[:locale] || extract_locale_from_tld)
      I18n.locale = session[:locale] = extract_locale_from_tld
    end
  
    # We overwrite the standard page_cache_path method to make it depend on the locale
    def self.page_cache_path(path, extension = nil)
      page_cache_directory.to_s + '/' + I18n.locale.to_s + page_cache_file(path, extension)
    end
  end
end
