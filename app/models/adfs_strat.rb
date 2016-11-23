# frozen_string_literal: true

module Coauth
    class AdfsStrat < CouchbaseOrm::Base
        design_document :adfs


        attribute :created_at, type: Integer, default: lambda { Time.now }
        attribute :name, type: String
        
        belongs_to :authority

        attribute :issuer, type: String, default: :cotag
        attribute :idp_sso_target_url_runtime_params, type: Hash, default: lambda { {
            email: :"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
            name: :"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name",
            metadata: :"http://tafesa.edu.au/identity/claims/DistinguishedName"
        } }
        attribute :name_identifier_format, type: String, default: lambda { 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified' }

        attribute :assertion_consumer_service_url, type: String
        attribute :idp_sso_target_url, type: String
        
        # TODO:: indicate all types
        attribute :idp_cert, type: String
        attribute :idp_cert_fingerprint, type: String
        attribute :idp_cert_fingerprint_validator

        attribute :attribute_service_name, type: String
        attribute :attribute_statements
        attribute :request_attributes


        protected


        validates :authority_id,    presence: true

        validates :issuer,                              presence: true
        validates :idp_sso_target_url,                  presence: true
        validates :name_identifier_format,              presence: true
        validates :assertion_consumer_service_url,      presence: true
        validates :idp_sso_target_url_runtime_params,   presence: true
    end
end
