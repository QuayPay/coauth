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
                redirect_to login_path    # angularjs code on the front end
            end
        end

        def verify 

            # Save any changes to the user model from params then
            # create an identity model if the password field isn't empty

            auth = session[:provider_id]
            @authentication = Authentication.from_omniauth(auth)
            u = User.create_with_omniauth(auth)
            @authentication.user_id = u.id
            @authentication.save
            u.name = params['name']
            u.email = params['email']
            u.save
            self.current_user = u
            if params['password'] != ''
                # Create identity and redirect back to sessions controller
                identity.create!(params)
                Authentication.create!({'uid' => params['email'], 'provider' => 'identity', 'user_id' => u.id})
                redirect_to '/login_success.html'
            else
                redirect_to '/login_success.html'
            end
        end
        
        def create
            # where do we want to redirect to with our new session
            path = session[:continue] || '/login_success.html'

            # Always reset the session
            tempuser = session[:user_id]
            reset_session
            session[:user_id] = tempuser


            #################### FIND OR CREATE AUTH ###############
            auth = request.env['omniauth.auth']
            p auth.id
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
                        redirect_to path
                    else
                        # TODO:: Multiple accounts code path
                    end
                else
                    @authentication.user_id = current_user.id
                    @authentication.save
                    current_user.save
                    redirect_to path
                end
            ########################################################

            # No user is signed_in
            else 

                #################### LOGGING IN VIA AUTH ###############
                if @authentication.user_id.present?
                    # The authentication we found had a user associated with it so let's 
                    # just log them in here
                    self.current_user = User.find_by_id(@authentication.user_id)
                    redirect_to path
                ########################################################
                
                # This auth has never logged in before
                else
             

                    session[:provider_id] = auth
                    #################### REGISTERING VIA AUTH ###############
                    if @authentication.provider == 'identity'
                        u = User.find(@authentication.uid)
                        @authentication.user_id = u.id
                        @authentication.save
                        # We can now link the authentication with the user and log him in
                        u.save
                        #UserMailer.welcome_email(u).deliver
                        self.current_user = u
                        redirect_to path
                        # If the provider is identity, then it means we already created a user
                        # So we just load it up

                    else
                        # otherwise we have to create a user with the auth hash
                        redirectstr = '/verify?'
                        redirectstr += 'name=' + auth.info.name unless (!(auth.info.first_name.nil? && auth.info.last_name.nil?))
                        redirectstr += 'first_name=' + auth.info.first_name unless auth.info.first_name.nil?
                        redirectstr += '&last_name=' + auth.info.last_name unless auth.info.last_name.nil?
                        redirectstr += '&email=' + auth.info.email unless auth.info.email.nil?
                        p redirectstr
                        redirect_to redirectstr
                        # u = User.create_with_omniauth(auth)
                        # @authentication.user_id = u.id
                        # @authentication.save
                        # NOTE: we will handle the different types of data we get back
                        # from providers at the model level in create_with_omniauth
                    end
                    # # We can now link the authentication with the user and log him in
                    # u.save
                    # #UserMailer.welcome_email(u).deliver
                    # self.current_user = u
                    # redirect_to path
                    #########################################################
                end

            end
        end
        
        def destroy
            p params
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