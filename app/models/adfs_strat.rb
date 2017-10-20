# frozen_string_literal: true

class AdfsStrat < CouchbaseOrm::Base
    design_document :adfs


    attribute :created_at, type: Integer, default: lambda { Time.now }
    attribute :name, type: String

    belongs_to :authority

    attribute :issuer, type: String, default: :aca
    attribute :idp_sso_target_url_runtime_params, type: Hash
    attribute :name_identifier_format, type: String, default: lambda { 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified' }
    attribute :uid_attribute, type: String

    attribute :assertion_consumer_service_url, type: String
    attribute :idp_sso_target_url, type: String

    attribute :idp_cert, type: String
    attribute :idp_cert_fingerprint, type: String

    attribute :attribute_service_name, type: String
    attribute :attribute_statements, type: Hash, default: lambda {
        {
            name: ["name"],
            email: ["email", "mail"],
            first_name: ["first_name", "firstname", "firstName", "givenname"],
            last_name: ["last_name", "lastname", "lastName", "surname"]
        }
    }
    attribute :request_attributes, type: Array, default: lambda {
        [
            { :name => 'ImmutableID', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Login Name' },
            { :name => 'email', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Email address' },
            { :name => 'name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Full name' },
            { :name => 'first_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Given name' },
            { :name => 'last_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Family name' }
        ]
    }

    attribute :idp_slo_target_url, type: String
    attribute :slo_default_relay_state, type: String


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

    validates :issuer,                         presence: true
    validates :idp_sso_target_url,             presence: true
    validates :name_identifier_format,         presence: true
    validates :assertion_consumer_service_url, presence: true
    validates :request_attributes,             presence: true
end
