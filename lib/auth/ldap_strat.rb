class LdapStrat < Couchbase::Model
    design_document :ldap

    include CouchbaseId::Generator

    attribute :created_at, default: lambda { Time.now.to_i }
    attribute :name  # (used as title)

    belongs_to :authority

    attribute :port, default: 636
    attribute :auth_method, default: :ssl
    attribute :uid, default: lambda { 'sAMAccountName' }
    attribute :host
    attribute :base
    attribute :bind_dn
    attribute :password   # This should not be plain text
    attribute :filter


    protected


    validates :authority_id,      presence: true
end
