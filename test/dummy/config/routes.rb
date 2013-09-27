Rails.application.routes.draw do

  mount Coauth::Engine => "/coauth"
end
