SemiStatic::Engine.routes.draw do
  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  if ActiveRecord::Base.connection.table_exists? 'semi_static_tags'
    SemiStatic::Tag.with_context_urls.collect{|t| t.name}.each do |tn|
      # Create routes for tag that create their own URL
      match "/#{tn.parameterize}/:id" => 'entries#show', :via => :get
    end
  end

  resources :fcols do
    resources :links
  end

  resources :entries, :no_context => true do
    collection { get :search }
    resources :click_ads, :only => [:new, :create, :update]
    resources :seos, :only => [:new, :create, :update, :destroy]
    resources :products, :except => [:index]
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

  match "/#{SemiStatic::Engine.config.tag_paths[I18n.locale.to_s] || 'features'}/:slug" => 'tags#show', :as => 'feature', :via => :get
  match "/features/:slug" => 'tags#show', :via => :get

  match "/page-attributes/index" => 'page_attrs#index', :as => 'page_attrs', :via => :get
  match "/page-attribute/:id" => 'page_attrs#destroy', :as => 'page_attr', :via => :delete
  match "/comments/index" => 'comments#index', :as => 'comments', :via => :get
  match "/documents/index" => 'documents#index', :as => 'documents', :via => :get
  match "/documents/:squeeze_id/:token" => 'documents#show', :as => 'document', :via => :get

  # Special route, normally only used by the webserver to get CSRF tags
  match '/site/csrf_meta_tags' => 'site#csrf_meta_tags'

  get '/site/home', to: redirect('/')
  match '/site/:content' => 'site#show', :as => 'site',
    :via => :get, :defaults => {:content => 'home'}

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
  match "/gallery" => 'galleries#index', :via => :get

  resources :squeezes
  resources :events, :except => :show
  resources :sidebars, :except => :show
  resources :products, :only => :index
  resources :newsletter_deliveries, :only => :update
  resources :subscribers do
    resources :newsletter_deliveries, :only => :index
  end
  resources :subscriber_categories, :only => [:new, :create, :destroy]
  resources :banners, :references
  resources :click_ads, :except => [:new, :create, :update]
  resources :seos, :except => [:new, :create, :update]
  resources :agreements

  match '/contacts/registration' => 'contacts#new', :as => 'new_registration', :via => :get
  resources :contacts, :except => [:edit, :update]

  match '/semi-static/dashboard' => 'dashboards#show', :as => 'semi_static_dashboard', :via => :get

  # All system cmd use update, even though they may really be doing a GET
  match '/system' => "system#update", :via => :put
end


