
Rails.application.routes.draw do
    scope :auth do
        use_doorkeeper

        get  '/login', to: 'auth/sessions#new'  # for defining continue
        get  '/logout', to: 'auth/sessions#destroy'  # for defining continue
        get  '/:provider/callback', to: 'auth/sessions#create' #omniauth route
        post '/:provider/callback', to: 'auth/sessions#create' #omniauth route

        post '/signup', to: 'auth/signups#create'  # manual account creation
    end
end
