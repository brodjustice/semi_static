module SignIn
  def after_sign_in_path_for(resource)
    if session[:user_intended_url].nil?
      url = semi_static.semi_static_dashboard_path
    else
      url = session[:user_intended_url].to_s
      session[:user_intended_url] = nil
    end
    url
  end

  def after_sign_out_path_for(resource)
    '/'
  end
end
