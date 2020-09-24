module SemiStatic
  class ApplicationController < ActionController::Base
    helper_method :current_order

    before_action :set_locale

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
      if defined?(User) && current_user && defined?(CanCan)
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
    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError do |e|
      #
      # We will try and find out what the person was looking for by checking the request URL. We grab the
      # base of the URL path and check to see if this matches any of our public tags.
      #
      @tags = []
      if (words_from_url = request.path.downcase.gsub(/[^a-z\s]/i, ' ')).present?
        @tags = Tag.is_public.select{|t| words_from_url.include?(t.title.downcase)}
      end
      @status_code = 404
      @exception = e
      @url = url_for(params.permit!)

      render :layout => 'semi_static_application', :template => 'semi_static/errors/show', :formats => [:html], :status => @status_code
    end

    # Bad AUTH Token
    rescue_from ActionController::InvalidAuthenticityToken do |e|
      @status_code = 422
      @exception = e
      @url = url_for(params.permit!)
      render :layout => 'semi_static_application', :template => 'semi_static/errors/show', :formats => [:html], :status => @status_code
    end

    rescue_from Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Errors::NotFound, Elasticsearch::Transport::Transport::Errors::BadRequest do |e|
      @status_code = 404
      @exception = e
      @url = url_for(params.permit!)
      respond_to do |format|
        format.html {
          render :layout => 'semi_static_application', :template => 'semi_static/errors/no_index', :status => @status_code
        }
        format.js {
          render :template => 'semi_static/errors/search_reindex'
        }
      end
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
      #
      # The Rails 3 version was as follows:
      #
      # if I18n.locale != (I18n.locale = session[:locale] = extract_locale_from_tld)
      #   Rails.application.reload_routes!
      # end
      #
      # This was probably done so that different domains with different locales could show the
      # same content. This is a bad idea straight away as this screws up the links between websites
      # and drives the search engines crazy. But even worse, in Rails 5 the calling reload_routes!
      # causes the Engine to extend "app.routes" everytime it is called with a new "find_script_name"
      # method, which will eventually case a very nasty stack overflow ( for example see:
      # /actionpack-5.2.4.4/lib/action_dispatch/routing/mapper.rb ).
      #
      # So we keep it simple:
      #
      I18n.locale = session[:locale] = extract_locale_from_tld
    end

    def self.page_cache_directory
      Rails.root.join("public", I18n.locale.to_s)
    end

    # Get the cart, and :paid cart cookies will be cleared 
    def current_order
      if !session[:order_id].nil?
        Order.find(session[:order_id])
      else
        Order.new
      end
    end

  end
end
