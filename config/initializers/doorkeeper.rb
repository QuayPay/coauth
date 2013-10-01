Doorkeeper.configure do
  orm :couchbase
  # This block will be called to check whether the
  # resource owner is authenticated or not
  resource_owner_authenticator do |routes|
    # Put your resource owner authentication logic here.
    # If you want to use named routes from your app you need
    # to call them on routes object eg.
    # routes.new_user_session_path

    # NOTE:: This is a security risk - could be used to steal a token (man in the middle attack)
    #user = User.find_by_id(session[:user_id])
    #if user
    #  session[:oauthparams] = request.parameters  # This is not a good idea
    #  user
    #else
    #  reset_session # prevent session fixation
    #  redirect_to('/login_required.html')
    #end

    User.find_by_id(session[:user_id]) || redirect_to('/login_required.html')
  end

  # If you want to restrict the access to the web interface for
  # adding oauth authorized applications you need to declare the
  # block below
  # admin_authenticator do |routes|
  #   # Put your admin authentication logic here.
  #   # If you want to use named routes from your app you need
  #   # to call them on routes object eg.
  #   # routes.new_admin_session_path
  #   Admin.find_by_id(session[:admin_id]) || redirect_to routes.new_admin_session_path
  # end

  resource_owner_from_credentials do
    warden.authenticate!(:scope => :user)
  end

  # Access token expiration time (default 2 hours)
  # access_token_expires_in 2.hours
  access_token_expires_in 5.minutes

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  default_scopes  :public
  optional_scopes :write
end
