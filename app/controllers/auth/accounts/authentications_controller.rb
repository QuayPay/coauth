module Auth
    module Accounts
        class AuthenticationsController < ApplicationController

            require 'uri'
            respond_to :json
            
           def index
              curr_user = current_user || User.find_by_id(doorkeeper_token.resource_owner_id.to_s)
            if curr_user
              response =  Authentication.by_user(curr_user.id)
            else
              response = nil
            end
            respond_with response
          end

            def destroy
                if signed_in?
                    auth_id = URI.parse(request.url.split("/").pop).to_s
                    if Authentication.find_by_id(auth_id).user_id == current_user.id
                        Authentication.find_by_id(auth_id).delete
                        if auth_id.split('::')[0] == 'auth-identity'
                            redirect_to '/accounts/identities/destroy/' + auth_id.split('::')[1]
                        else
                            render :nothing => true, :status => :ok
                        end
                        
                    end
                else
                end
                
            end
        end
    end
end
