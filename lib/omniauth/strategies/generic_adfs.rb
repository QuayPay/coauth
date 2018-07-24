require 'omniauth/strategies/saml'

module OmniAuth
    module Strategies
        class GenericAdfs < OmniAuth::Strategies::SAML
            include CurrentAuthorityHelper


            option :name, 'generic_adfs'


            def aca_configure_opts
                authid = request.params['id']
                if authid.nil?
                    raise 'no auth definition ID provided'
                else
                    set_options(authid)
                end
            end

            def request_phase
                aca_configure_opts
                session.clear
                super
            end

            def callback_phase
                aca_configure_opts
                super
            end

            def other_phase
                if current_path.start_with?(request_path)
                    aca_configure_opts
                    super
                else
                    call_app!
                end
            end

            DEFAULT_CERT_VALIDATOR = lambda { |fingerprint| fingerprint }
            def set_options(id)
                strat = AdfsStrat.find(id)

                authority = current_authority.try(:id)
                raise 'invalid authentication source' unless authority == strat.authority_id

                options.title = strat.name
                options.issuer = strat.issuer
                options.idp_sso_target_url_runtime_params = strat.idp_sso_target_url_runtime_params
                options.name_identifier_format = strat.name_identifier_format
                options.uid_attribute = strat.uid_attribute if strat.uid_attribute
                options.assertion_consumer_service_url = strat.assertion_consumer_service_url
                options.idp_sso_target_url = strat.idp_sso_target_url

                options.idp_cert = strat.idp_cert if strat.idp_cert
                options.idp_cert_fingerprint = strat.idp_cert_fingerprint if strat.idp_cert_fingerprint
                options.idp_cert_fingerprint_validator = strat.idp_cert_fingerprint_validator if strat.idp_cert_fingerprint_validator
                options.request_attributes = strat.request_attributes if strat.request_attributes
                options.attribute_service_name = strat.attribute_service_name if strat.attribute_service_name
                options.attribute_statements = strat.attribute_statements if strat.attribute_statements
                options.info_params_map = strat.info_params_map if strat.info_params_map

                options.allowed_clock_drift = 5.seconds
                options.idp_cert_fingerprint_validator = DEFAULT_CERT_VALIDATOR
            end
        end
    end
end
