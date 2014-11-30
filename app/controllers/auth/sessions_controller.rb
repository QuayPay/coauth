require 'net/http'
require 'uri'
require 'set'


module Auth
    class SessionsController < CoauthController
        OMNIAUTH = 'omniauth.auth'.freeze
        UID = 'uid'.freeze
        PROVIDER = 'provider'.freeze

        SKIP_PARAMS = Set.new(['urls', 'Website']) # Params we don't want to send to register


        # Inline login
        def new
            details = params.permit(:provider, :continue)
            remove_session
            set_continue(details[:continue])
            redirect_to "/auth/#{details[:provider]}", :status => :see_other
        end


        # Local login
        def signin
            details = params.permit(:email, :password, :continue)
            user_id = User.bucket.get("useremail-#{details[:email]}", {quiet: true})
            if user_id
                user = User.find(user_id)
                if user && user.authenticate(details[:password])
                    path = details[:continue]
                    remove_session
                    new_session(user)

                    # If there is a path we are using an inline login form
                    if path
                        redirect_to path
                    else
                        render nothing: true, status: :accepted
                    end

                    Auth::Authentication.after_login_block.call(user)
                else
                    login_failure(details)
                end
            else
                login_failure(details)
            end
        end


        #
        # Run each time a user logs in via social
        #
        def create
            # Where do we want to redirect to with our new session
            path = cookies.encrypted[:continue] || success_path

            # Get auth hash from omniauth
            auth = request.env[OMNIAUTH]

            # Find an authentication or create an authentication
            auth_model = ::Auth::Authentication.from_omniauth(auth)

            if auth_model.nil? && signed_in?
                # Adding a new auth to existing user
                ::Auth::Authentication.create_with_omniauth(auth, current_user.id)
                redirect_to path
                Auth::Authentication.after_login_block.call(current_user)

            elsif auth_model.nil?
                user = ::User.new(safe_params(auth.info))
                if user.save
                    ::Auth::Authentication.create_with_omniauth(auth, user.id)
                    # TODO:: Consider what to do here on error...
                    # i.e user created without auth due to database fail

                    # Set the user in the session and complete the auth process
                    remove_session
                    new_session(user)
                    redirect_to path
                    Auth::Authentication.after_login_block.call(user)
                else
                    # TODO:: check if existing user has any authentications
                    # This works around the possible database error above.

                    # Where /signup is a client side application
                    store_social(auth[UID], auth[PROVIDER])
                    redirect_to '/signup/index.html?' + auth_params_string(auth.info)
                end

            else
                # Log-in the user currently authenticating
                remove_session if signed_in?
                user = User.find_by_id(auth_model.user_id)
                new_session(user)
                redirect_to path
                Auth::Authentication.after_login_block.call(user)
            end
        end

        # Log off
        def destroy
            remove_session
            redirect_to (params.permit(:continue)[:continue] || '/')
        end


        protected


        def safe_params(authinfo)
            ::ActionController::Parameters.new(authinfo).permit(:name, :email, :password, :password_confirmation, :metadata)
        end

        def auth_params_string(authinfo)
            authinfo.map {|k,v| "#{k}=#{URI.encode_www_form_component(v)}" unless SKIP_PARAMS.include?(k)}.compact.join('&')
        end

        def login_failure(details)
            path = details[:continue]
            if path
                # TODO:: need to add query component to indicate that the request was a failure
                redirect_to request.referer || '/' # login failed, reload the page
            else
                render nothing: true, status: :unauthorized
            end
        end
    end
end
