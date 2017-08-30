# frozen_string_literal: true

Rails.application.routes.draw do
    scope :auth do
        use_doorkeeper

        get  '/login', to: 'auth/sessions#new'       # for defining continue
        get  '/logout', to: 'auth/sessions#destroy'  # deletes the session
        get  '/:provider/callback', to: 'auth/sessions#create' # omniauth route
        post '/:provider/callback', to: 'auth/sessions#create' # omniauth route

        post '/signin', to: 'auth/sessions#signin'   # local account login
        post '/signup', to: 'auth/signups#create'    # manual account creation

        get  '/failure', to: 'auth/signups#show'      # Auth failure message

        # Refresh tokens for web apps
        post '/token', to: 'auth/trusts#create'

        get  '/authority', to: 'auth/authorities#current'
    end

    namespace :auth do
        namespace :api do
            resources :applications
            resources :domains
            resources :authsources
        end
    end
end
