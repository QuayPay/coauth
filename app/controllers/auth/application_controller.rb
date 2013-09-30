module Auth
  class ApplicationController < ActionController::Base
    include ApplicationHelper
      
      
  private

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user 

    def signed_in?
      !!current_user
    end
    helper_method :signed_in?
   
    def current_user=(user)
      @current_user = user
      session[:user_id] = user.nil? ? user : user.id
    end
  end
end
