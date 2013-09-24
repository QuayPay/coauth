OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :developer unless Rails.env.production?
	provider :open_id, :name => 'google', :store => OpenID::Store::CouchStore.new(Couchbase.bucket), :identifier => 'https://www.google.com/accounts/o8/id'
	provider :twitter, 'KqhFk1O3ejNoPlNo28Fg1Q', 'zj2ojB7YBS4kjB4oED10rS7ciGxJbEGA9P8IlNoYEqA'
	provider :facebook, '169794839854264', 'a8c136ef1b8597a3ac47c763e76fb669'
	provider :identity, on_failed_registration: lambda { |env|      
    IdentitiesController.action(:new).call(env)  
  }
end
