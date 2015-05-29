SemiStatic::Engine.routes.draw do
  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  resources :fcols do
    resources :links
  end

  resources :entries do
    collection { get :search }
    resources :seos, :only => [:new, :create, :update]
    resources :products, :except => [:index]
    resources :photos, :only => :index
  end

  resources :tags, :except => :show do
    resources :seos, :only => [:new, :create, :update]
    resources :entries, :only => [:index]
  end

  match "/#{SemiStatic::Engine.config.tag_paths[I18n.locale.to_s] || 'features'}/:slug" => 'tags#show', :as => 'feature', :via => :get
  match "/features/:slug" => 'tags#show', :via => :get

  match "/documents/index" => 'documents#index', :as => 'documents', :via => :get

  match '/site/:content' => 'site#show', :as => 'site',
    :via => :get, :defaults => {:content => 'home'}

  root :to => 'site#show', :as => 'home', :via => :get, :defaults => { :content => 'home' }

  get "site/show"

  resources :newsletters do
    resources :newsletter_deliveries, :only => :index
  end

  resources :photos do
    resources :seos, :only => [:new, :create, :update]
  end

  resources :products, :only => :index
  resources :newsletter_deliveries, :only => :update
  resources :subscribers
  resources :banners, :references
  resources :seos, :except => [:new, :create, :update]
  resources :agreements
  resources :contacts, :except => [:edit, :update]

  match '/semi-static/dashboard' => 'dashboards#show', :as => 'semi_static_dashboard', :via => :get

  match '/system' => "system#update", :via => :put
end


