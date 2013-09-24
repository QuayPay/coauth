module Accounts
	class IdentitiesController < ApplicationController


		  def new
    		@identity = env['omniauth.identity']
		  end

		  def destroy
		  	ident_id = request.url.split("/").pop
		  	p Identity.find_by_id(ident_id)
		  	Identity.find_by_id(ident_id).delete
		  	render :nothing => true, :status => :ok
		  end
		#
		# TODO:: inform user that a password reset is not possible
		# 	should add additional sources of identity (i.e. facebook)
		#
		

	end
end
