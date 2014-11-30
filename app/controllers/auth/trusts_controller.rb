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


        # Add headers to allow for CORS requests to the API
        after_filter :allow_cors
        around_action :enhance_trust_request, only: :create


        # This provides a refresh token to web applications
        # Note:: There is the potential for abuse - although slim
        def enhance_trust_request
            safe = trusts_safe_params

            if safe[:grant_type] == 'authorization_code'
                app, secret = get_trust_data(safe[:client_id])

                # Make the now enhanced OAuth request
                yield
                extract_and_save_token(app)
            elsif safe[:grant_type] == 'refresh_token'
                app, secret = get_trust_data(safe[:client_id])
                token = safe[:refresh_token]

                if token
                    # Grab the refresh token from the cookie (we used passed in redirect uri this time)
                    key   = ActiveSupport::KeyGenerator.new(safe[:redirect_uri]).generate_key(secret)
                    crypt = ActiveSupport::MessageEncryptor.new(key)
                    request.parameters['refresh_token'] = crypt.decrypt_and_verify(token)

                    # Make the now enhanced OAuth request
                    yield
                    extract_and_save_token(app)
                else
                    # fail the request
                    response.status = 400
                    render nothing: true, status: :bad_request
                end
            else
                # fail the request
                response.status = 400
                render nothing: true, status: :bad_request
            end
        end


        def options
            render nothing: true
        end


        private


        def trusts_safe_params
            params.permit(:grant_type, :client_id, :code, :refresh_token, :redirect_uri)
        end

        def get_trust_data(client_id)
            app = ::Doorkeeper::Application.find(client_id)
            secret = app.secret

            # fill in the information required to complete the OAuth request
            request.parameters['client_secret'] = secret
            return app, secret
        end

        def extract_and_save_token(app)
            return unless response.status == 200
            remove_session # Only happens when request came from the same domain

            # Grab the data we need
            redirect = app.redirect_uri
            secret = app.secret

            # Extract the refresh token from the response
            resp_data = ::ActiveSupport::JSON.decode response.body

            # Encrypt it using the redirect_uri as the password and secret as the salt
            key   = ActiveSupport::KeyGenerator.new(redirect).generate_key(secret)
            crypt = ActiveSupport::MessageEncryptor.new(key)
            resp_data['refresh_token'] = crypt.encrypt_and_sign(resp_data['refresh_token'])

            response.body = ::ActiveSupport::JSON.encode resp_data
        end

        # Don't keep re-creating these objects for every request
        ALLOW_ORIGIN = 'Access-Control-Allow-Origin'.freeze
        ALLOW_METHODS = 'Access-Control-Allow-Methods'.freeze
        ALLOW_HEADERS = 'Access-Control-Allow-Headers'.freeze
        MAX_AGE = 'Access-Control-Max-Age'.freeze
        ANY_ORIGIN = '*'.freeze
        ANY_METHOD = 'GET, POST, PUT, DELETE, OPTIONS, PATCH'.freeze
        COMMON_HEADERS = 'Origin, Accept, Content-Type, X-Requested-With, Authorization, X-Frame-Options'.freeze
        ONE_DAY = '1728000'.freeze

        def allow_cors
            headers[ALLOW_ORIGIN] = ANY_ORIGIN
            headers[ALLOW_METHODS] = ANY_METHOD
            headers[ALLOW_HEADERS] = COMMON_HEADERS
            headers[MAX_AGE] = ONE_DAY
        end
    end
end
