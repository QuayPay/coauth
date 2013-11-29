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

       
        
        def create

            if signed_in?
                if User.find_by_id(session[:user_id]).guest == true
                    # If the currently logged in user is a guest, then log them out and create a new account
                    p' resetting session'
                    reset_session
                end
            end
            #UserMailer.welcome_email(u).deliver

            # where do we want to redirect to with our new session
            path = session[:continue] || '/login_success.html'

            # Always reset the session
            tempuser = session[:user_id]
            reset_session
            session[:user_id] = tempuser


            auth = request.env['omniauth.auth']

            # Find an authentication or create an authentication
            @authentication = Authentication.from_omniauth(auth)
            
            if @authentication.nil?
                
                # If no authentication was found, create a brand new one here
                # @authentication = Authentication.create_with_omniauth(auth)

                if signed_in? # User is signed in and therefore adding provider
                    @authentication = Authentication.create_with_omniauth(auth)
                    @authentication.user_id = current_user.id
                    @authentication.save
                    redirect_to path
                   
                else 
                    # Auth provider is identity, we already have a user model
                    if auth['provider'] == 'identity'
                        @authentication = Authentication.create_with_omniauth(auth)
                        u = User.find(@authentication.uid)
                        @authentication.user_id = u.id
                        @authentication.save
                        u.save
                        self.current_user = u
                        redirect_to path
                    elsif auth['provider'] == 'facebook'
                        reset_session
                        @authentication = Auth::Authentication.create!({'provider' => auth['provider'], 'uid' => auth['uid']})
                        newuser = User.create!({:user => {:name => auth.info.name, :email => auth.info.email}})
                        @authentication.user_id = newuser.id
                        @authentication.save
                        self.current_user = newuser
                        redirect_to '/login_success.html'
                    else
                        session[:uid] = auth['uid']
                        session[:provider] = auth['provider']
                        
                        redirectstr = '/register?'
                        redirectstr += 'name=' + auth.info.name unless (!(auth.info.first_name.nil? && auth.info.last_name.nil?))
                        redirectstr += 'first_name=' + auth.info.first_name unless auth.info.first_name.nil?
                        redirectstr += '&last_name=' + auth.info.last_name unless auth.info.last_name.nil?
                        redirectstr += '&email=' + auth.info.email unless auth.info.email.nil?
                        redirectstr += '&verify=true'
                        #redirectstr += '&image=' + auth.info.image.sub('type=square','type=large') unless auth.info.image.nil?
                        redirect_to redirectstr
                       
                    end
                end
            else
                if signed_in?
                    # User already signed in and auth already exists...
                    # Either their re-adding a provider or adding one already linked to another account
                    if @authentication.user_id == current_user.id
                        redirect_to path
                    else
                        # TODO:: Multiple accounts code path
                    end
                else
                    # No user signed in but auth exists... Log the user in
                    self.current_user = User.find_by_id(@authentication.user_id)
                    redirect_to path
                end
            end
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