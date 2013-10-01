module Auth
    module ApplicationHelper
        def success_path
            '/login_success.html'
        end

        def login_path
            '/login'
        end
    end
end
