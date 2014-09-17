require 'securerandom'

module Auth
    class CoauthController < ActionController::Base
        include Auth::UserHelper 

        def success_path
            '/login_success.html'
        end

        def login_path
            '/login'
        end
        
        
        protected


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
            value[:secure] = Rails.env.production?
            cookies.encrypted[:user] = value
        end

        def store_social(uid, provider)
            value = {
                value: {
                    uid: uid,
                    provider: provider,
                    salt: SecureRandom.hex[0..(1 + rand(15))]   # Variable length
                },
                httponly: true,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = Rails.env.production?
            cookies.encrypted[:social] = value
        end

        def set_continue(path)
            value = {
                value: path,
                httponly: true,
                path: '/auth'   # only sent to calls at this path
            }
            value[:secure] = Rails.env.production?
            cookies.encrypted[:continue] = value
        end
    end
end
