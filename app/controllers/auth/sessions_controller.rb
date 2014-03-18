require 'net/http'
require 'uri'
require 'set'


module Auth
    class SessionsController < ApplicationController
        OMNIAUTH = 'omniauth.auth'.freeze
        UID = 'uid'.freeze
        PROVIDER = 'provider'.freeze

        SKIP_PARAMS = Set.new(['urls', 'Website']) # Params we don't want to send to register


        # Redirect to continue
        def index
            path = session[:continue] || '/'
            session.delete(:continue)
            redirect_to path
        end


        # Inline login
        def new
            details = params.permit(:provider, :continue)
            remove_session
            session[:continue] = details[:continue]
            redirect_to "/auth/#{details[:provider]}", :status => :see_other
        end

       
        #
        # Run each time a user logs in via social
        #
        def create
            # Where do we want to redirect to with our new session
            path = session[:continue] || success_path

            # Get auth hash from omniauth
            auth = request.env[OMNIAUTH]

            # Find an authentication or create an authentication
            auth_model = Authentication.from_omniauth(auth)
            
            if auth_model.nil? && signed_in?
                # Adding a new auth to existing user
                auth_model = Authentication.create_with_omniauth(auth)
                auth_model.user_id = current_user.id
                auth_model.save
                redirect_to path

            elsif auth_model.nil?
                user = ::User.from_omniauth(safe_params(auth.info))
                if user.save
                    auth = Auth::Authentication.new({provider: auth[PROVIDER], uid: auth[UID]})
                    auth.user_id = user.id
                    auth.save

                    # Set the user in the session and complete the auth process
                    remove_session
                    new_session(user)
                    redirect_to path
                else
                    # Where /signup is a client side application
                    store_social(auth[UID], auth[PROVIDER])
                    redirect_to '/signup?' + auth_params_string(auth.info)
                end

            else
                # Log-in the user currently authenticating
                remove_session if signed_in?
                new_session(User.find_by_id(auth_model.user_id))
                redirect_to path
            end
        end

        # Log off
        def destroy
            remove_session
            redirect_to (params.permit(:continue)[:continue] || root_path)
        end


        protected


        def safe_params(authinfo)
            ::ActionController::Parameters.new(authinfo).permit(:name, :email, :password, :password_confirmation)
        end

        def auth_params_string(authinfo)
            authinfo.map{|k,v| "#{k}=#{v}" unless SKIP_PARAMS.include?(k)}.reject{|x| x.nil? }.join('&')
        end
    end
end
