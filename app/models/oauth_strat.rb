# frozen_string_literal: true

class OauthStrat < CouchbaseOrm::Base
    design_document :oauths


    attribute :created_at, type: Integer, default: lambda { Time.now }
    attribute :name,       type: String

    belongs_to :authority

    attribute :client_id,      type: String
    attribute :client_secret,  type: String
    attribute :info_mappings,  type: Hash
    attribute :site,           type: String
    attribute :authorize_url,  type: String
    attribute :token_method,   type: String
    attribute :auth_scheme,    type: String
    attribute :token_url,      type: String
    attribute :scope,          type: String
    attribute :raw_info_url,   type: String


    # Provides find_by_name function
    index_view :name


    def type
        self.class.design_document
    end

    def type=(type)
        raise 'bad type' unless type.to_s == self.class.design_document
    end

    def serializable_hash(**options)
        options = {
            methods: :type
        }.merge!(options)
        super(**options)
    end


    protected


    validates :authority_id, presence: true
    validates :name,         presence: true
end
