module CanCanRescue

  require 'cancan'

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
end
