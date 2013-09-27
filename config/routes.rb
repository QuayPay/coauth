Coauth::Engine.routes.draw do
	use_doorkeeper
	get '/:provider/callback', to: 'sessions#create' #omniauth route
	post '/:provider/callback', to: 'sessions#create' #omniauth route


	namespace :accounts do
		resources :authentications, :users
		post '/identities/destroy/:id', to: 'identities#destroy'
	end
end
