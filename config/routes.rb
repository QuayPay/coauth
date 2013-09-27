Coauth::Engine.routes.draw do
    use_doorkeeper
    get '/:provider/callback', to: 'coauth/sessions#create' #omniauth route
    post '/:provider/callback', to: 'coauth/sessions#create' #omniauth route

    namespace :coauth do
        namespace :accounts do
            resources :authentications, :users
            post '/identities/destroy/:id', to: 'identities#destroy'
        end
    end
end
