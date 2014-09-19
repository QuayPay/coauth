require 'net/http'
require 'uri'
require 'set'

require 'securerandom'


module Auth
    class TrustsController < Doorkeeper::TokensController
        # We need access to cookies and filters
        include ActionController::Helpers
        include ActionController::StrongParameters
        include ActionController::Cookies
        include AbstractController::Callbacks
        include ActionController::ParamsWrapper

        # current_user and remove_session
        include Auth::UserHelper


        around_action :enhance_trust_request, only: :create


        # This provides a secure refresh token to un-trusted sources
        # uses the users session instead of client secret for initial
        # refresh token generation (when using access grant)
        #
        # It then destroys the session data to avoid abuse
        # 1 x session === 1 x refresh token
        # We then store a lifetime cookie, that we can verify, as the refresh token
        def enhance_trust_request
            safe = trusts_safe_params

            if safe[:grant_type] == 'authorization_code'
                if current_user
                    app, secret = get_trust_data(safe[:client_id])

                    # Make the now enhanced OAuth request
                    yield
                    extract_and_save_token(app)
                else
                    # fail the request - not authenticated
                    response.status = 401
                    render nothing: true, status: :unauthorized
                end
            elsif safe[:grant_type] == 'refresh_token'
                app, secret = get_trust_data(safe[:client_id])
                token = cookies.encrypted[cookie_name(app)]

                if token
                    # Grab the refresh token from the cookie (we used passed in redirect uri this time)
                    key   = ActiveSupport::KeyGenerator.new(safe[:redirect_uri]).generate_key(secret)
                    crypt = ActiveSupport::MessageEncryptor.new(key)
                    token = crypt.decrypt_and_verify(token)
                    request.parameters['refresh_token'] = token

                    # Make the now enhanced OAuth request
                    yield
                    extract_and_save_token(app)
                else
                    # fail the request
                    response.status = 401
                    render nothing: true, status: :unauthorized
                end
            else
                # fail the request
                response.status = 400
                render nothing: true, status: :bad_request
            end
        end


        def destroy
            safe = trusts_safe_params
            app = ::Doorkeeper::Application.find(safe[:client_id])
            remove_trust(app)
            render nothing: true
        end


        private


        def trusts_safe_params
            params.permit(:grant_type, :client_id, :code, :redirect_uri)
        end

        def get_trust_data(client_id)
            app = ::Doorkeeper::Application.find(client_id)
            secret = app.secret

            # fill in the information required to complete the OAuth request
            request.parameters['client_secret'] = secret
            return app, secret
        end

        def remove_trust(app)
            remove_session
            cookies.delete(cookie_name(app), path: '/auth')
        end

        def cookie_name(app)
            "trust-#{app.name}"
        end

        def extract_and_save_token(app)
            return unless response.status == 200
            remove_trust(app)

            # Grab the data we need
            redirect = app.redirect_uri
            secret = app.secret
            cookie = cookie_name(app)

            # Extract the refresh token from the response
            resp_data = ::ActiveSupport::JSON.decode response.body
            token = resp_data.delete 'refresh_token'
            response.body = ::ActiveSupport::JSON.encode resp_data

            # Encrypt it using the redirect_uri as the password and secret as the salt
            key   = ActiveSupport::KeyGenerator.new(redirect).generate_key(secret)
            crypt = ActiveSupport::MessageEncryptor.new(key)
            token = crypt.encrypt_and_sign(token)

            # Set the token as an encrypted cookie
            value = {
                value: token,
                httponly: true,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = Rails.env.production?
            cookies.permanent.encrypted[cookie] = value
        end
    end
end
