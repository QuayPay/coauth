# frozen_string_literal: true

module Auth
    class AuthoritiesController < ActionController::Base
        include UserHelper
        include CurrentAuthorityHelper
        
        def current
            auth = current_authority.as_json(except: [:created_at, :internals])
            auth[:session] = signed_in?
            render json: auth
        end
    end
end
