module Auth
    class AuthoritiesController < ActionController::Base
        include CurrentAuthorityHelper
        
        def current
            render json: current_authority.as_json(except: [:created_at])
        end
    end
end
