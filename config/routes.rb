
Rails.application.routes.draw do
    scope :auth do
        use_doorkeeper

        get  '/login', to: 'auth/sessions#new'       # for defining continue
        get  '/logout', to: 'auth/sessions#destroy'  # deletes the session
        get  '/:provider/callback', to: 'auth/sessions#create' # omniauth route
        post '/:provider/callback', to: 'auth/sessions#create' # omniauth route

        post '/signin', to: 'auth/sessions#signin'   # local account login
        post '/signup', to: 'auth/signups#create'    # manual account creation

        get '/failure', to: 'auth/signups#show'      # Auth failure message

        # Refresh tokens for web apps
        post   '/token', to: 'auth/trusts#create'
        match  '/token' => 'auth/trusts#options', :via => :options
    end
end
