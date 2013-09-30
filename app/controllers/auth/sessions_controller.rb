module Auth
  class SessionsController < ApplicationController
    #
    # NOTE:: This is required for OpenId Providers to prevent the session being lost 
    #

      def new
      # Stuff to display on the login-page.
    end
    
    def create

     
      #################### SET OAUTH URL PARAMS ##############
      if session[:oauthparams]
        oauth = true
        rtype = 'response_type=' + session[:oauthparams][:response_type]
        ruri = 'redirect_uri=' + session[:oauthparams][:redirect_uri]
        cid = 'client_id=' + session[:oauthparams][:client_id]
        oauthparams = rtype + '&' + ruri + '&' + cid
        path = '/ext_oauth.html' + oauthparams
        tempuser = session[:user_id]
        reset_session
        session[:user_id] = tempuser
      else
        path = '/ext_oauth.html'
      end
      ########################################################


      #################### FIND OR CREATE AUTH ###############
      auth = request.env['omniauth.auth']
      # Find an authentication or create an authentication
      @authentication = Authentication.from_omniauth(auth)
      if @authentication.nil?
        # If no authentication was found, create a brand new one here
        @authentication = Authentication.create_with_omniauth(auth)
      end
      ########################################################


      #################### USER ADDING AUTH ###############
      if signed_in?
        if @authentication.user_id.present?
          if @authentication.user_id == current_user.id
            redirect_to path, notice: "You have already linked this account."
          else
            redirect_to path
          end
        else
          update_user(auth)
          @authentication.user_id = current_user.id
          @authentication.save
          current_user.save
          redirect_to path, notice: "Account successfully authenticated"
        end
      ########################################################

      # No user is signed_in
      else 

        #################### LOGGING IN VIA AUTH ###############
        if @authentication.user_id.present?
          # The authentication we found had a user associated with it so let's 
          # just log them in here
          self.current_user = User.find_by_id(@authentication.user_id)
          redirect_to path  #redirect_to root_path, notice: "Signed in!"
        ########################################################
        
        # This auth has never logged in before
        else
       


          #################### REGISTERING VIA AUTH ###############
          if @authentication.provider == 'identity'
            u = User.find(@authentication.uid)
            @authentication.user_id = u.id
            @authentication.save
            ident = '&identity=true'
            # If the provider is identity, then it means we already created a user
            # So we just load it up
          else
            # otherwise we have to create a user with the auth hash
            u = User.create_with_omniauth(auth)
            @authentication.user_id = u.id
            @authentication.save
            # NOTE: we will handle the different types of data we get back
            # from providers at the model level in create_with_omniauth
          end
          # We can now link the authentication with the user and log him in
          u.save
          #UserMailer.welcome_email(u).deliver
          self.current_user = u
          if oauth
            # If registering to obtain an oAuth token, redirect to add a card
            redirect_to '/cards?' + oauthparams + (ident ||= "")  
          else
            redirect_to path
          end
          #########################################################
        end

      end
    end
    
    def destroy
      p params
      if params['redirect_uri']
        path = params['redirect_uri']
      else
        path = '/'
      end
      self.current_user = nil
      reset_session
      redirect_to path, notice: "Signed out!"
    end
    
    def failure  
      redirect_to '/', alert: "Authentication failed, please try again."  
    end

    def update_user(auth)
      current_user.email = auth['info']['email'] unless auth['info']['email'].nil?
      current_user.name = auth['info']['name'] unless auth['info']['name'].nil?
      current_user.save
    end
  end

end