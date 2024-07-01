SemiStatic::Engine.routes.draw do
  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  # Set the root of the website to the Site controller
  root :action => 'show', :via => :get, :controller => 'site'
  # And also define home_path as the root
  get '/' => 'site#show', :as => 'home'

  #
  # For Tags that put their name in the url ("context_urls").
  #
  # For example if the Tag was called 'blog', then rather than the standard:
  #   /entries/278-my-great-page
  # we would have:
  #   /blog/278-my-great-page
  # The controller would redirect /entries/278-my-great-page to /blog/278-my-great-page
  #
  # We only provide GET routes, which means that edit/update of the Entry with
  # POST/PUT/PATCH will not work. But since this is only ever done in the admin
  # dashboard we choose to deal this by hand (see form_for in entries/_form.html.haml)
  #
  if ActiveRecord::Base.connection.table_exists? 'semi_static_tags'
    SemiStatic::Tag.with_context_urls.collect{|t| t.name.parameterize}.each do |tn|
      # Shortened routes for SemiStatic Tags, the Tag name is in the URL
      # and needs to be passed to the controller as the :slug parameter
      get "/#{tn}", to: 'tags#show', :slug => "#{tn}"

      # Create routes for tag that create their own URL
      get "/#{tn}/:id" => 'entries#show'
    end
  end

  if SemiStatic::Engine.config.tag_paths.present?
    #
    # For prettier Tag URLs. Without this your URL for a Tag index page call 'blog' would be
    #   /tag/blog
    # With this you can set the Tag URL's. By default in english it is "features", the URL above would no be
    #   /features/blog
    # see config/initializers/semi_static.rb
    #
    # We create the routes for all the different locales while the "features_path" helper creates the
    # correct url in the webpage itself depending on the locale. Currently that means that all
    # the locale versions of the website will respond to all the urls in SemiStatic::Engine.config.tag_paths which
    # is probably not optimal, so we raise error in TagsController
    SemiStatic::Engine.config.tag_paths.keys.each do |l|
      get "/#{SemiStatic::Engine.config.tag_paths[l]}/:slug" => 'tags#show', :as => "#{l}_features"
    end
  else

    get '/news' => 'tags#show', :slug => 'news'
  end

  # In case the Entry is not served by a Tag with a context_url
  resources :entries, :only => :show
  get '/search' => 'entries#search', :as => 'search'

  resources :contacts
  get '/contact', :to => redirect('/contacts/new')
  get '/contacts/registration' => 'contacts#new', :as => 'new_registration'



  resources :sitemaps, :only => :index

  # Public galleries path
  get "/gallery", :to => 'galleries#index', :as => 'public_galleries'

  get "/order/:id" => "carts#show", :as => 'shopping-cart'

  # Public documents paths
  get "/documents" => 'documents#index', :as => 'documents'
  get "/documents/index" => 'documents#index'
  get "/documents/:squeeze_id/:token" => 'documents#show', :as => 'document'

  ###################################################################################
  #
  # SemiStatic scoped routes below
  #

  scope 'semi-static' do
    resources :entries, :except => :show do
      collection { get :search }
      resources :click_ads, :only => [:new, :create, :update]
      resources :seos, :only => [:new, :create, :update, :destroy]
      resources :products, :except => [:index, :show]
      resources :photos, :only => :index
      resources :comments, :except => :new
      resources :page_attrs, :except => :index
    end

    resources :fcols do
      resources :links, :except => :show
    end

    resources :seos do
      resources :hreflangs, :except => :show
    end

    # Catch all for the Tag route with slug when no context_url is used etc
    #      get "/#{tn}", to: 'tags#show', :slug => "#{tn}"
    resources :tags, :only => :show, :param => :slug

    resources :tags, :except => :show do
      resources :seos, :only => [:new, :create, :update, :destroy]
      resources :entries, :only => [:index]
      resources :page_attrs, :except => :index
    end

    # The route /gallery is reserved to the pre-defined Gallery Tag which
    # displays the websites public photos selected from various SemiStatic
    # Galleries
    resources :galleries, :as => 'galleries'
    resources :photos do
      resources :seos, :only => [:new, :create, :update]
    end

    # For the orders and shopping carts, the carts index is actually
    # the orders but serviced by the orders controller. The cart is
    # actually the current_order, there is no ID for it, it's in the
    # session cookie, so the URL does not have and :id
    resource :cart, only: [:show, :edit, :update]
    resources :carts, only: [:index]
    resources :order_items, only: [:create, :update, :destroy]

    # Note the need to put provide the explict path, else the defined route with clash with the
    # contact_path routes outside of the semi-static scope
    resources :contacts, :path => 'contacts', :as => 'contacts', :only => [:show, :index, :destroy]

    resources :charges, :only => [:new, :create]

    resources :newsletters do
      resources :newsletter_deliveries, :only => :index
    end

    resources :squeezes do
      resources :page_attrs, :except => :index
    end

    resources :job_postings
    resources :events, :except => :show
    resources :sidebars
    resources :products
    resources :newsletter_deliveries, :only => :update
    resources :subscribers, :except => :show do
      resources :newsletter_deliveries, :only => :index
    end
    resources :subscriber_categories, :only => [:new, :create, :destroy]
    resources :banners
    resources :references
    resources :click_ads, :except => [:new, :create, :update]
    resources :seos, :except => [:new, :create, :update]
    resources :agreements
  end

  # For the payment processor (stripe.com)

  get "/semi-static/page-attributes/index" => 'page_attrs#index', :as => 'page_attrs'
  delete "/semi-static/page-attribute/:id" => 'page_attrs#destroy', :as => 'page_attr'
  get "/comments/index" => 'comments#index', :as => 'comments'


  # Special route, normally only used by the webserver to get CSRF tags
  get '/site/csrf_meta_tags' => 'site#csrf_meta_tags'

  get '/site/:content' => 'site#show', :as => 'site'

  get "site/show"




  get '/semi-static/dashboard' => 'dashboards#show', :as => 'semi_static_dashboard'

  # Most system cmd use update, even though they often are not posting anything
  put '/system' => "system#update"
  get '/system/show' => "system#show"
end
