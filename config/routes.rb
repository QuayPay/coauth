#Coauth::Engine.routes.draw do
# Works better for doorkeeper
Rails.application.routes.draw do
   

    namespace :auth do
      
        namespace :accounts do
            resources :authentications, :users
            post '/identities/destroy/:id', to: 'identities#destroy'
        end
    end
    scope :auth do
        use_doorkeeper
      get '/:provider/callback', to: 'auth/sessions#create' #omniauth route
      post '/:provider/callback', to: 'auth/sessions#create' #omniauth route
    end
end
