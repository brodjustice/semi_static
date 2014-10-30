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
  end

  resources :banners, :references, :photos
  resources :seos, :except => [:new, :create, :update]
  resources :agreements
  resources :contacts, :except => [:edit, :update]
  resources :tags, :except => :show do
    resources :seos, :only => [:new, :create, :update]
  end

  match '/features/:slug' => 'tags#show', :as => 'feature', :via => :get

  match '/site/:content' => 'site#show', :as => 'site',
    :via => :get, :defaults => {:content => 'home'}

  root :to => 'site#show', :as => 'home', :via => :get,
    :defaults => { :content => 'home' }

  get "site/show"

  # devise_for :users, class_name: "SemiStatic::User", module: :devise

  devise_for :users, class_name: "SemiStatic::User", module: :devise do
    get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  match '/user/:role/dashboard' => 'dashboards#show', :as => 'dashboard', :via => :get

  resources :users
  match '/system' => "system#update", :via => :put
end


