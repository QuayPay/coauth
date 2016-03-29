class AdfsStrat < Couchbase::Model
    design_document :adfs

    include CouchbaseId::Generator

    attribute :created_at, default: lambda { Time.now.to_i }
    attribute :name
    
    belongs_to :authority

    attribute :issuer, default: :cotag
    attribute :idp_sso_target_url_runtime_params, default: lambda { {
        email: :"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
        name: :"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name",
        metadata: :"http://tafesa.edu.au/identity/claims/DistinguishedName"
    } }
    attribute :name_identifier_format, default: lambda { 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified' }

    attribute :assertion_consumer_service_url
    attribute :idp_sso_target_url
    
    attribute :idp_cert
    attribute :idp_cert_fingerprint
    attribute :idp_cert_fingerprint_validator
    attribute :request_attributes
    attribute :attribute_service_name
    attribute :attribute_statements


    protected


    validates :authority_id,    presence: true

    validates :issuer,                              presence: true
    validates :idp_sso_target_url,                  presence: true
    validates :name_identifier_format,              presence: true
    validates :assertion_consumer_service_url,      presence: true
    validates :idp_sso_target_url_runtime_params,   presence: true
end
