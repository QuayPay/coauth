require 'omniauth/strategies/ldap'
require 'omniauth-ldap'

module OmniAuth
    module Strategies
        class GenericLdap < OmniAuth::Strategies::LDAP

            option :name, 'generic_ldap'


            def request_phase
                authid = request.params['id']
                if authid.nil?
                    raise 'no auth definition ID provided'
                else
                    set_options(authid)
                end

                session['omniauth.auth_id'] = authid

                super
            end

            def callback_phase
                authid = session.delete 'omniauth.auth_id'

                # Set out details once again
                if authid.nil?
                    raise 'no auth definition ID provided'
                else
                    set_options(authid)
                end

                super
            end

            def set_options(id)
                strat = LdapStrat.find(id)

                options.title = strat.name
                options.port = strat.port
                options.method = strat.auth_method.to_sym if strat.auth_method
                options.encryption.to_sym if options.encryption
                options.uid = strat.uid
                options.host = strat.host
                options.base = strat.base
                options.bind_dn = strat.bind_dn
                options.password = strat.password
            end
        end
    end
end
