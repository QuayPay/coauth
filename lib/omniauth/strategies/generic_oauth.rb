require 'multi_json'
require 'jwt'
require 'omniauth/strategies/oauth2'

if Rails.env.development?
    module OmniAuth
        module Strategy
            def full_host
                uri = URI.parse(request.url)
                uri.path = ''
                uri.query = nil
                uri.port = 3000
                uri.to_s
            end
        end
    end
end

module OmniAuth
    module Strategies
        class GenericOauth < OmniAuth::Strategies::OAuth2

            option :name, 'generic_oauth'

            uid {
                raw_info[options.client_options.info_mappings['uid']].to_s
            }

            info do
                data = {}
                options.client_options.info_mappings.each do |key, value|
                  data[key] = raw_info[value]
                end
                data
            end

            def request_phase
                authid = request.params['id']
                if authid.nil?
                    raise 'no auth definition ID provided'
                else
                    set_options(authid)
                end
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

            def authorize_params
                session.clear
                session['omniauth.auth_id'] = request.params['id']
                super
            end

            def set_options(id)
                strat = OauthStrat.find(id)

                options.client_options.site = strat.site if strat.site
                options.client_options.use_authorize = strat.use_authorize if strat.use_authorize
                options.client_options.authorize_url = strat.authorize_url if strat.authorize_url
                options.client_options.authorize_path = strat.authorize_path  if strat.authorize_path
                options.client_options.token_url = strat.token_url  if strat.token_url
                options.client_options.raw_info_url = strat.raw_info_url if strat.raw_info_url
                options.client_options.info_mappings = strat.info_mappings if strat.info_mappings

                options.authorize_params.scope = strat.scope

                options.client_id = strat.client_id
                options.client_secret = strat.client_secret
            end

            def access_token_options
                options.access_token_options.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }
            end

            def callback_url
                full_host + script_name + callback_path + "?id=" + request.params['id']
            end

            def raw_info
                if !@raw_info.nil?
                    p @raw_info
                end
                @raw_info ||= access_token.get(options.client_options.raw_info_url).parsed
            end

            def prune!(hash)
                hash.delete_if do |_, value|
                    prune!(value) if value.is_a?(Hash)
                    value.nil? || (value.respond_to?(:empty?) && value.empty?)
                end
            end

        end
    end
end
