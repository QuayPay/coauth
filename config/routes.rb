
Rails.application.routes.draw do
    namespace :auth do
        get '/service', to: 'sessions#service_login', as: :service_login    # for continue params
    end
    scope :auth do
        use_doorkeeper
        get  '/:provider/callback', to: 'auth/sessions#create' #omniauth route
        post '/:provider/callback', to: 'auth/sessions#create' #omniauth route?


        post '/signup', to: 'auth/signups#create'  # manual account creation
        get  '/login', to: 'auth/sessions#new'  # for defining continue
    end
end
