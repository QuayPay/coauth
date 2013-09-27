module Coauth
	module Accounts
		class UsersController < ApplicationController
			respond_to :json

			def new
				 @user = env['omniauth.identity'] ||= User.new
			end

			def update
				respond_with :accounts, User.find(params[:id]).update_attributes(user_params).save
			end

			def show
				if session['user_id']
					respond_with User.find(session['user_id'])
				else
					 render :file => "public/401.html", :status => :unauthorized, :layout => false
				end
						
			end

			def index

			
				
			end


			protected


			def user_params
				params.require(:user).permit(:email, :first_name, :last_name, :address1, :address2, :country, :city, :state, :post_code, :mobile, :work)
			end
		end
	end
end
