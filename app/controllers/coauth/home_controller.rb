module Coauth
    class HomeController < Coauth::ApplicationController

      def index
          if current_user
              curr_user = session["warden.user.user.key"]
              reset_session
              session["warden.user.user.key"] = curr_user
          end
          redirect_to "/login"
      end
    end
end
