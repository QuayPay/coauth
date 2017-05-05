class Strat < Couchbase::Model
    design_document :strat

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


    view :by_name, :show_all
    def self.by_name(name)
        by_name({:key => [name], :stale => false})  
    end

    def self.all
      show_all({:key => nil, :include_docs => true, :stale => false})
    end

    def self.lookup(id)
        return self.find_by_id("strat--#{id}")
    end
end