
module Auth
    class SignupsController < ApplicationController
        respond_to :json


        def show
            render text: "Authentication Failed: #{params.permit(:message)[:message]}"
        end

        def create
            # Can't create a user if you are already logged in.
            if cookies.signed[:user]
                render(nothing: true, status: :forbidden)

            # No user logged in check if they are signing in using a social auth
            else
                # Grab redirect information - continue == inline auth and success_path == popup
                path = session[:continue] || success_path
                social = cookies.signed[:social]

                if social    # UID == social auth
                    # Grab data from cookie and prevent session fixation
                    uid = social[:uid]
                    provider = social[:provider]
                    
                    # Create the user
                    # TODO:: in case of crash, we need to check if user can't be created due to
                    #        existing user account with no authentications
                    user = User.new(safe_params)
                    if user.save
                        auth = Auth::Authentication.new({provider: provider, uid: uid})
                        auth.user_id = user.id
                        auth.save

                        # Set the user in the session and complete the auth process
                        remove_session
                        new_session(user)
                        
                        # we're in a pop-up so redirect to a page that can communicate to the main page
                        redirect_to path
                    else
                        # Email address taken (all other validation can be checked on the client)
                        render(nothing: true, status: :conflict)
                    end
                else
                    # This is manual sign up form
                    user = User.create(safe_params)
                    if user
                        remove_session
                        new_session(user)
                        redirect_to path
                    else
                        # Email address taken
                        render nothing: true, status: :conflict
                    end
                end
            end
        end


        protected


        def safe_params
            params.permit(:name, :nickname, :password, :password_confirmation, :email)
        end
    end
end
