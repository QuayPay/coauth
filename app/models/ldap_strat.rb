# frozen_string_literal: true

class LdapStrat < CouchbaseOrm::Base
    design_document :ldaps


    attribute :created_at, type: Integer, default: lambda { Time.now }
    attribute :name,       type: String  # (used as title)

    belongs_to :authority

    attribute :port,        type: Integer, default: 636
    attribute :auth_method, type: String,  default: :ssl
    attribute :uid,         type: String,  default: lambda { 'sAMAccountName' }
    attribute :host,        type: String
    attribute :base,        type: String
    attribute :bind_dn,     type: String
    attribute :password,    type: String  # This should not be plain text
    attribute :filter


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
    validates :host,         presence: true
    validates :base,         presence: true
end
