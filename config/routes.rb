Rails.application.routes.draw do
	
	use_doorkeeper
	get '/auth/:provider/callback', to: 'sessions#create' #omniauth route
	post '/auth/:provider/callback', to: 'sessions#create' #omniauth route
  

	namespace :accounts do    
		resources :authentications, :cards, :users
		post 'pay', to: 'cards#pay'
		post '/identities/destroy/:id', to: 'identities#destroy'
	end


end