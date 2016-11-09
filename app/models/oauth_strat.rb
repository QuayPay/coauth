
class OauthStrat < CouchbaseOrm::Base
    design_document :oauth


    attribute :created_at, type: Integer, default: lambda { Time.now }

    attribute :name,           type: String
    attribute :client_id,      type: String
    attribute :client_secret,  type: String
    attribute :info_mappings,  type: Hash
    attribute :site,           type: String
    attribute :authorize_url,  type: String
    attribute :authorize_path, type: String
    attribute :use_authorize,  type: Boolean
    attribute :token_url,      type: String
    attribute :credential_url, type: String
    attribute :uid,            type: String
    attribute :scope,          type: String
    attribute :raw_info_url,   type: String


    # Provides find_by_name function
    index_view :name
end
