SemiStatic::Engine.routes.draw do
  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

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
    SemiStatic::Tag.with_context_urls.collect{|t| t.name}.each do |tn|
      # Create routes for tag that create their own URL
      get "/#{tn.parameterize}/:id" => 'entries#show'
    end
  end

  resources :fcols do
    resources :links, :except => :show
  end

  resources :entries do
    collection { get :search }
    resources :click_ads, :only => [:new, :create, :update]
    resources :seos, :only => [:new, :create, :update, :destroy]
    resources :products, :except => [:index, :show]
    resources :photos, :only => :index
    resources :comments, :except => :new
    resources :page_attrs, :except => :index
  end

  resources :seo, :only => [] do
    resources :hreflangs, :except => :show
  end

  resources :tags, :except => :show do
    resources :seos, :only => [:new, :create, :update, :destroy]
    resources :entries, :only => [:index]
    resources :page_attrs, :except => :index
  end

  # For the orders and shopping carts, the carts index is actually
  # the orders but serviced by the orders controller. The cart is
  # actually the current_order, there is no ID for it, it's in the 
  # session cookie, so the URL does not have and :id
  resource :cart, only: [:show, :edit, :update]
  resources :carts, only: [:index]
  resources :order_items, only: [:create, :update, :destroy]
  get "/order/:id" => "carts#show", :as => 'shopping-cart'

  # For the payment processor (stripe.com)
  resources :charges, :only => [:new, :create]

  #
  # For prettier Tag URLs. Without this your URL for a Tag index page call 'blog' would be
  #   /tag/blog
  # With this you can set the Tag URL's. By default in english it is "features", the URL above would no be
  #   /features/blog
  # see config/initializers/semi_static.rb
  get "/#{SemiStatic::Engine.config.tag_paths[I18n.locale.to_s] || 'features'}/:slug" => 'tags#show', :as => 'feature'

  get "/page-attributes/index" => 'page_attrs#index', :as => 'page_attrs'
  delete "/page-attribute/:id" => 'page_attrs#destroy', :as => 'page_attr'
  get "/comments/index" => 'comments#index', :as => 'comments'
  get "/documents/index" => 'documents#index', :as => 'documents'
  get "/documents/:squeeze_id/:token" => 'documents#show', :as => 'document'

  # Special route, normally only used by the webserver to get CSRF tags
  get '/site/csrf_meta_tags' => 'site#csrf_meta_tags'

  get '/site/home', to: redirect('/')
  get '/site/:content' => 'site#show', :as => 'site', :defaults => {:content => 'home'}

  root :to => 'site#show', :as => 'home', :via => :get, :defaults => { :content => 'home' }

  get "site/show"

  resources :newsletters do
    resources :newsletter_deliveries, :only => :index
  end

  # The route /gallery is reserved to the pre-defined Gallery Tag which
  # displays the websites public photos selected from various SemiStatic
  # Galleries
  resources :galleries
  resources :photos do
    resources :seos, :only => [:new, :create, :update]
  end
  get "/gallery" => 'galleries#index'

  resources :squeezes
  resources :job_postings
  resources :events, :except => :show
  resources :sidebars
  resources :products
  resources :newsletter_deliveries, :only => :update
  resources :subscribers, :except => :show do
    resources :newsletter_deliveries, :only => :index
  end
  resources :subscriber_categories, :only => [:new, :create, :destroy]
  resources :banners, :references
  resources :click_ads, :except => [:new, :create, :update]
  resources :seos, :except => [:new, :create, :update]
  resources :agreements

  get '/contacts/registration' => 'contacts#new', :as => 'new_registration'
  resources :contacts, :except => [:edit, :update]

  get '/semi-static/dashboard' => 'dashboards#show', :as => 'semi_static_dashboard'

  # Most system cmd use update, even though they may really not posting anything
  put '/system' => "system#update"
  get '/system/show' => "system#show"
end


