module SignIn
  def after_sign_in_path_for(resource)
    if current_admin
      url = semi_static.semi_static_dashboard_path
    elsif session[:user_intended_url]
      url = session[:user_intended_url].to_s
      session[:user_intended_url] = nil
    else
      url = main_app.send(SemiStatic::Engine.config.subscribers_model.first[0].downcase + '_dashboard_path')
    end
    url
  end

  def after_sign_out_path_for(resource)
    '/'
  end
end
