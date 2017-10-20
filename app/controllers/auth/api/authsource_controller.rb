# frozen_string_literal: true

module Auth
    module Api
        class AuthsourcesController < Base
            before_action :check_admin
            before_action :find_authsource, only: [:show, :update, :destroy]


            @@elastic ||= Elastic.new
            DOC_TYPES = ['adfs', 'ldaps', 'oauths']
            SEARCH_FILTER = {'doc.type' => DOC_TYPES}

            def index
                query = @@elastic.query(params)
                # Multiple document types
                query.or_filter(SEARCH_FILTER)

                # Specific domain
                authority_id = params.permit(:authority_id)[:authority_id]
                query.filter({'doc.authority_id' => [authority_id]}) if authority_id

                # Any user level filters
                query.sort = NAME_SORT_ASC
                query.search_field 'doc.name'

                render json: @@elastic.search(query)
            end

            def show
                render json: @authsource
            end

            def update
                @authsource.assign_attributes(safe_params)
                save_and_respond @authsource
            end

            def create
                args = safe_params
                auth = case args[:type].to_sym
                when :adfs
                    ::AdfsStrat.new(args)
                when :ldaps
                    ::LdapStrat.new(args)
                when :oauths
                    ::OauthStrat.new(args)
                end
                save_and_respond auth
            end

            def destroy
                @authsource.destroy
                head :ok
            end


            protected


            AUTH_PARAMS = [
                :type, :name, :authority_id,
                # SAML
                :issuer, :name_identifier_format, :assertion_consumer_service_url, :idp_sso_target_url,
                :idp_cert, :idp_cert_fingerprint, :attribute_service_name, :idp_slo_target_url,
                :slo_default_relay_state, :uid_attribute,
                # LDAP
                :port, :auth_method, :uid, :host, :base, :bind_dn, :password, :filter,
                # OAuth
                :client_id, :client_secret, :site, :authorize_url, :token_method, :auth_scheme, 
                :token_url, :scope, :raw_info_url
            ]
            def safe_params
                args = params.permit(AUTH_PARAMS).to_h

                case args[:type].to_sym
                when :ldaps, :oauths
                    get_hash(args, :info_mappings)
                when :adfs
                    get_hash(args, :idp_sso_target_url_runtime_params)
                    get_hash(args, :attribute_statements)

                    # Extracts an array of hashes
                    args[:request_attributes] = params.extract!(:request_attributes)
                        .permit![:request_attributes]&.collect { |att| att.to_unsafe_hash }
                    args.delete(:request_attributes) unless args[:request_attributes].present?
                else
                    raise 'bad request'
                end

                args
            end

            def find_authsource
                # Find will raise a 404 (not found) then we need to check the document type
                @authsource = ::CouchbaseOrm.try_load(id)
                head(:not_acceptable) unless DOC_TYPES.include?(@authsource.class.design_document)
            end

            def get_hash(args, key)
                hash = params[key]
                args[key] = hash.to_unsafe_hash if hash
                args.delete(key) unless args[key].present?
            end
        end
    end
end
