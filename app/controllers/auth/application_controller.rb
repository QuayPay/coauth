require 'securerandom'

module Auth
    class ApplicationController < ActionController::Base
        def success_path
            '/login_success.html'
        end

        def login_path
            '/login'
        end
        
        
        protected


        def remove_session
            cookies.delete(:user,   path: '/auth')
            cookies.delete(:social, path: '/auth')
            reset_session
            @current_user = nil
        end

        def new_session(user)
            @current_user = user
            value = {
                value: {
                    id: user.id,
                    salt: SecureRandom.hex[0..(1 + rand(31))]   # Variable length 1->32
                },
                httponly: true,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = true if Rails.env.production?
            cookies.signed[:user] = value
        end

        def store_social(uid, provider)
            value = {
                value: {
                    uid: uid,
                    provider: provider
                },
                httponly: true,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = true if Rails.env.production?
            cookies.signed[:social] = value
        end

        def current_user
            user = cookies.signed[:user]
            @current_user ||= User.find(user[:id]) if user
        end

        def signed_in?
            !!current_user
        end
    end
end
