require 'set'
require 'doorkeeper'
require 'doorkeeper-jwt'

Doorkeeper.configure do
    orm :couchbase
    access_token_generator '::Doorkeeper::JWT'

    # This block will be called to check whether the
    # resource owner is authenticated or not
    resource_owner_authenticator do |routes|
        # We use cookies signed instead of session as then we can limit
        # the cookie to particular paths (i.e. /auth)
        begin
            cookie = cookies.encrypted[:user]
            user = User.find_by_id(cookie[:id]) if cookie
            user || redirect_to('/login_required.html')
        rescue TypeError
            cookies.delete(:user,   path: '/auth')
            cookies.delete(:social, path: '/auth')
            cookies.delete(:continue, path: '/auth')
            redirect_to('/login_required.html')
        end
    end

    # restrict the access to the web interface for adding
    # oauth authorized applications
    if Rails.env.production?
        admin_authenticator do |routes|
            admin = begin
                user = User.find(cookies.encrypted[:user][:id])
                user.sys_admin == true
            rescue
                false
            end
            render nothing: true, status: :not_found unless admin
        end
    else
        admin_authenticator do |routes|
            true
        end
    end

    # Skip authorization only if the app is owned by us
    if Rails.env.production?
        skip_authorization do |resource_owner, client|
            client.application.skip_authorization
        end
    else
        skip_authorization do |resource_owner, client|
            true
        end
    end

    # username and password authentication for local auth
    resource_owner_from_credentials do |routes|
        user_id = User.bucket.get("useremail-#{User.process_email(params[:authority], params[:username])}", {quiet: true})
        if user_id
            user = User.find(user_id)
            if user && user.authenticate(params[:password])
                user
            end
        end
    end

    # Issue access tokens with refresh token (disabled by default)
    access_token_expires_in 2.weeks
    use_refresh_token

    # Define access token scopes for your provider
    # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
    default_scopes  :public
    optional_scopes :admin

    force_ssl_in_redirect_uri false
    grant_flows %w(authorization_code client_credentials implicit password)
end

::Doorkeeper::JWT.configure do
    # Set the payload for the JWT token. This should contain unique information
    # about the user.
    # Defaults to a randomly generated token in a hash
    # { token: "RANDOM-TOKEN" }
    token_payload do |opts|
        user = User.find(opts[:resource_owner_id])

        {
            iss: 'My App',
            iat: Time.current.utc.to_i,
            jti: SecureRandom.uuid, # @see JWT reserved claims - https://tools.ietf.org/html/draft-jones-json-web-token-07#page-7

            user: {
                id: user.id,
                name: user.name,
                email: user.email
            }
        }
    end

    # Optionally set additional headers for the JWT. See https://tools.ietf.org/html/rfc7515#section-4.1
    token_headers do |opts|
        {
            kid: opts[:application][:uid]
        }
    end

    # Use the application secret specified in the Access Grant token
    # Defaults to false
    # If you specify `use_application_secret true`
    use_application_secret true

    # Specify encryption type. Supports any algorithm in
    # https://github.com/progrium/ruby-jwt
    # defaults to nil
    encryption_method :hs512
end
