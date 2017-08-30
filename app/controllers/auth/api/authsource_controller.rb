# frozen_string_literal: true

module Auth
    module Api
        class AuthsourceController < Base
            before_action :check_admin
            before_action :find_authsource, only: [:show, :update, :destroy]


            @@elastic ||= Elastic.new
            SEARCH_FILTER = {'doc.type' => ['adfs', 'ldaps', 'oauths']}

            def index
                query = @@elastic.query(params)
                query.or_filter(SEARCH_FILTER)
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
                type = params.permit(:type)[:type]
                auth = case type.to_sym
                when :adfs
                    ::Authority.new(safe_params)
                when :ldap
                    ::Authority.new(safe_params)
                when :oauth
                    ::Authority.new(safe_params)
                end
                save_and_respond auth
            end

            def destroy
                @authsource.destroy
                head :ok
            end


            protected


            AUTHORITY_PARAMS = [
                :name, :dom, :description, :login_url, :logout_url
            ]
            def safe_params
                internals = params[:internals]
                config = params[:config]

                args = params.permit(AUTHORITY_PARAMS).to_h
                args[:internals] = internals.to_unsafe_hash if internals
                args[:config] = config.to_unsafe_hash if config
                args
            end

            def find_authsource
                # Find will raise a 404 (not found)
                @authsource = ::CouchbaseOrm.try_load(id)
            end
        end
    end
end
