# frozen_string_literal: true

require 'omniauth/strategies/ldap'
require 'omniauth-ldap'

module OmniAuth
    module Strategies
        class GenericLdap < OmniAuth::Strategies::LDAP
            include Coauth::CurrentAuthorityHelper


            option :name, 'generic_adfs'


            def request_phase
                authid = request.params['id']
                if authid.nil?
                    raise 'no auth definition ID provided'
                else
                    set_options(authid)
                end

                session.clear

                super
            end

            def callback_phase
                authid = request.params['id']

                # Set out details once again
                if authid.nil?
                    raise 'no auth definition ID provided'
                else
                    set_options(authid)
                end

                super
            end

            def set_options(id)
                strat = AdfsStrat.find(id)

                authority = current_authority.try(:id)
                raise 'invalid authentication source' unless authority == strat.authority_id

                options.title = strat.name
                options.issuer = strat.issuer
                options.idp_sso_target_url_runtime_params = strat.idp_sso_target_url_runtime_params
                options.name_identifier_format = strat.name_identifier_format
                options.assertion_consumer_service_url = strat.assertion_consumer_service_url
                options.idp_sso_target_url = strat.idp_sso_target_url

                options.idp_cert = strat.idp_cert if strat.idp_cert
                options.idp_cert_fingerprint = strat.idp_cert_fingerprint if strat.idp_cert_fingerprint
                options.idp_cert_fingerprint_validator = strat.idp_cert_fingerprint_validator if strat.idp_cert_fingerprint_validator
                options.request_attributes = strat.request_attributes if strat.request_attributes
                options.attribute_service_name = strat.attribute_service_name if strat.attribute_service_name
                options.attribute_statements = strat.attribute_statements if strat.attribute_statements
            end
        end
    end
end
