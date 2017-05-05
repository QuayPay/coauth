require 'multi_json'
require 'jwt'
require 'omniauth/strategies/oauth2'
require 'open-uri'

module OmniAuth
    module Strategies
        class Generic < OmniAuth::Strategies::OAuth2

            option :name, 'generic'

		    uid { 
		    	Rails.logger.info "Got heres"
		    	Rails.logger.info raw_info
		    	Rails.logger.info raw_info["ID"]
		    	Rails.logger.info options.client_options.info_mappings['uid'].class
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
		    	if !request.params.key?('id')
	          	# Some error
	          else
	          	set_options(request.params['id'])
	          end
	          super
		    end

		    def callback_phase
		    	# Set out details once again
		    	if !request.params.key?('id')
		    		# Some error
		    	else
	          		set_options(request.params['id'])
		    	end

	          super
		    end

		    def set_options(id)
		    	strat = Strat.lookup(request.params['id']) 
		    	if strat.nil?
		    		# Some error
		    	end

		    	options.name = request.params['id']
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

		    def raw_info
		    	if !@raw_info.nil?
		    		Rails.logger.info @raw_info
		    	end
		    	Rails.logger.info "Getting raw info with details:"
		    	Rails.logger.info access_token.token
		    	Rails.logger.info options.client_options.raw_info_url
		    	# @raw_info ||= ::RestClient.get(options.client_options.raw_info_url + "?access_token=" + access_token.token)
		        # @raw_info ||= access_token.get(options.client_options.raw_info_url).parsed


				@raw_info ||= JSON.parse(open(options.client_options.raw_info_url + "?access_token=" + access_token.token).read)

				Rails.logger.info "Raw info:"
				Rails.logger.info @raw_info 
				@raw_info
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
