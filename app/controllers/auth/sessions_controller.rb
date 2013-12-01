require 'net/http'
require 'uri'
module Auth
    class SessionsController < ApplicationController

        #
        # Full screen redirect authentication options
        #
        def service_login
            path = params[:continue] || request.referer || root_path

            if signed_in?
                tempuser = session[:user_id]
                reset_session
                session[:user_id] = tempuser
                redirect_to path
            else
                reset_session
                session[:continue] = path
                redirect_to login_path + '?continue=' + session[:continue]    # angularjs code on the front end
            end
        end

       
        #
        # Run each time a user logs in via social or identity auth
        #
        def create
            
            # If the currently logged in user is a guest, then log them out and create a new account
            if signed_in? && User.find_by_id(session[:user_id]).guest == true
                reset_session
            end

            # Where do we want to redirect to with our new session
            path = session[:continue] || '/login_success.html'

            # Always reset the session
            tempuser = session[:user_id]
            reset_session
            session[:user_id] = tempuser

            # Get auth hash from omniauth
            auth = request.env['omniauth.auth']

            # Find an authentication or create an authentication
            @authentication = Authentication.from_omniauth(auth)
            
            if @authentication.nil? && signed_in?

                # Adding a new auth to existing user
                omniauth_login(auth, path)          

            elsif @authentication.nil?

                # Auth provider is identity, we already have a user model
                if auth['provider'] == 'identity'
                    omniauth_login(auth, path)
                end

                # Set session variables so they can be accessed by the API 
                session[:uid] = auth['uid']
                session[:provider] = auth['provider']

                # Providers to bypass register page - move this to env variable
                bypass_register = ['facebook', 'twitter']

                # Params returned by omniauth which we don't want to send as params to register
                skip_params = ['urls', 'nickname', 'Website']

                # Bypass registration page if provider is in array
                if bypass_register.include?(auth['provider'])
                    redirect_to '/api/v1/register?' + auth_params_string(auth.info, skip_params)     
                else
                    redirect_to '/register?' + auth_params_string(auth.info, skip_params)
                end

            elsif signed_in?

                # Either they're re-adding a provider or adding one already linked to another account
                if @authentication.user_id == current_user.id
                    redirect_to path
                else
                    # TODO:: Multiple accounts code path, we probably wont get here for a while
                end

            else

                # No user signed in but auth exists... Log the user in
                self.current_user = User.find_by_id(@authentication.user_id)
                redirect_to path
                
            end
        end
        
        #
        # Creates an authentication, associates the user with it and logs them in if not already
        #
        def omniauth_login(auth, path)
            @authentication = Authentication.create_with_omniauth(auth)
            if signed_in?
                user = User.find(@authentication.uid)
                self.current_user = user
            end
            @authentication.user_id = current_user.id
            @authentication.save
            redirect_to path
        end

        def auth_params_string(authinfo, skip)
            return authinfo.map{|k,v| "#{k}=#{v}" unless skip.include?(k)}.reject{|x| x.nil? }.join('&')
        end

        def destroy
            if params['redirect_uri']
                path = params['redirect_uri']
            else
                path = root_path
            end
            self.current_user = nil
            reset_session
            redirect_to path, notice: "Signed out!"
        end
        
        def failure    
            redirect_to root_path, alert: "Authentication failed, please try again."
        end

    end

end