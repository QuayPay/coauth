Rails.application.routes.draw do
	use_doorkeeper
    get '/auth/:provider/callback', to: 'sessions#create' #omniauth route
    post '/auth/:provider/callback', to: 'sessions#create' #omniauth route
   
end