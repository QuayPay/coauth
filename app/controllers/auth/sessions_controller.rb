require 'net/http'
require 'uri'
require 'set'


module Auth
    class SessionsController < CoauthController
        OMNIAUTH = 'omniauth.auth'.freeze
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
            authority = current_authority
            
            user_id = User.bucket.get("useremail-#{User.process_email(authority.id, details[:email])}", {quiet: true})

            if user_id
                user = User.find(user_id)
                if user && user.authenticate(details[:password])
                    path = details[:continue] || cookies.encrypted[:continue]
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

            if auth.nil?
                return login_failure({})
            end

            # Find an authentication or create an authentication
            auth_model = ::Auth::Authentication.from_omniauth(auth)

            # adding a new auth to existing user
            if auth_model.nil? && signed_in?
                logger.info "User signed in and re-authenticating"

                ::Auth::Authentication.create_with_omniauth(auth, current_user.id)
                redirect_to path
                Auth::Authentication.after_login_block.call(current_user)

            # new auth and new user
            elsif auth_model.nil?
                args = safe_params(auth.info)
                user = ::User.new(args)

                # Use last name and first name by preference
                fn = args[:first_name]
                if fn && !fn.empty?
                    user.name = "#{fn} #{args[:last_name]}"
                end

                authority = current_authority

                existing = ::User.find_by_email(authority.id, user.email)
                user = existing if existing
                user.deleted = false if user.respond_to?(:deleted)

                user.authority_id = authority.id

                # now the user record is initialised (but not yet saved), give
                # the installation the opportunity to modify the user record or
                # reject the signup outright
                result = Auth::Authentication.before_signup_block.call(user, auth[PROVIDER], auth)

                logger.info "Creating new user: #{result.inspect}\n#{user.inspect}"
                
                if result != false && user.save
                    # user is created, associate an auth record or raise exception
                    Auth::Authentication.create_with_omniauth(auth, user.id)

                    # make the new user the currently logged in user
                    remove_session
                    new_session(user)

                    # redirect the user to the page they were trying to access and
                    # run any custom post-login actions
                    redirect_to path
                    Auth::Authentication.after_login_block.call(user, auth[PROVIDER], auth)
                else
                    logger.info "User save failed: #{user.errors.messages}"

                    # user save failed (db or validation error) or the before
                    # signup block returned false. redirect back to a signup
                    # page, where /signup is a required client side path.
                    store_social(auth[UID], auth[PROVIDER])
                    redirect_to '/signup/index.html?' + auth_params_string(auth.info)
                end

            # existing auth and existing user
            else
                begin
                    # Log-in the user currently authenticating
                    remove_session if signed_in?
                    user = User.find_by_id(auth_model.user_id)
                    new_session(user)
                    redirect_to path
                    Auth::Authentication.after_login_block.call(user)
                rescue => e
                    logger.error "Error with user account. Possibly due to a database failure:\nAuth model: #{auth_model.inspect}\n#{e.inspect}"
                    raise e
                end
            end
        end

        # Log off
        def destroy
            remove_session
            redirect_to (params.permit(:continue)[:continue] || '/')
        end


        protected


        def safe_params(authinfo)
            ::ActionController::Parameters.new(authinfo).permit(:name, :first_name, :last_name, :email, :password, :password_confirmation, :metadata)
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
