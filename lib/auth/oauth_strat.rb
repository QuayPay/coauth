class OauthStrat < Couchbase::Model
    design_document :oauth

    include CouchbaseId::Generator
    extend EnsureUnique

    attribute :created_at, default: lambda { Time.now.to_i }

    attribute :name
    attribute :client_id
    attribute :client_secret
    attribute :info_mappings
    attribute :site
    attribute :authorize_url
    attribute :authorize_path
    attribute :use_authorize
    attribute :token_url
    attribute :credential_url
    attribute :uid
    attribute :scope
    attribute :raw_info_url


    view :by_name
    def self.by_name(name)
        by_name({:key => [name], :stale => false})  
    end
end
