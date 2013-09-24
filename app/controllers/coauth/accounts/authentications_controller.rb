module Accounts
	class AuthenticationsController < ApplicationController

		require 'uri'
		respond_to :json
		
		
		def index
			if current_user
			response =  Authentication.by_user({:key => [current_user.id]})
			end
			respond_with response
		end
		
		def destroy
			if signed_in?
				auth_id = URI.parse(request.url.split("/").pop).to_s
				p auth_id
				if Authentication.find_by_id(auth_id).user_id == current_user.id
					Authentication.find_by_id(auth_id).delete
					if auth_id.split('::')[0] == 'auth-identity'
						redirect_to '/accounts/identities/destroy/' + auth_id.split('::')[1]
					else
						render :nothing => true, :status => :ok
					end
					
				end
			else
				p 'NOPE'
			end
			
		end
	end
end
