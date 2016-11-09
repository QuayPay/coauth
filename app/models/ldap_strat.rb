
class LdapStrat < CouchbaseOrm::Base
    design_document :ldap


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


    protected


    validates :authority_id,      presence: true
end
