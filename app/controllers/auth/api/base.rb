# frozen_string_literal: true

module Auth
    module Api
        class UserNotFound < StandardError; end
        
        class Base < ActionController::API
            NAME_SORT_ASC ||= [{
                'doc.name.sort' => {
                    order: :asc
                }
            }]


            before_action :doorkeeper_authorize!
            rescue_from ::CouchbaseOrm::Error::RecordInvalid, with: :invalid_record
            rescue_from ::Libcouchbase::Error::KeyNotFound,   with: :entry_not_found
            rescue_from ::Libcouchbase::Error::NetworkError,  with: :service_unavailable
            rescue_from UserNotFound,  with: :token_invalid


            protected


            # This defines current_authority from coauth/lib/auth/authority
            include CurrentAuthorityHelper


            # Couchbase catch all
            def entry_not_found(err)
                logger.warn err.message
                logger.warn err.backtrace.join("\n") if err.respond_to?(:backtrace) && err.backtrace
                head :not_found  # 404
            end

            def invalid_record(err)
                errors = err.record.errors
                render json: errors, status: :not_acceptable  # 406
            end


            # Helper for extracting the id from the request
            def id
                return @id if @id
                params.require(:id)
                @id = params.permit(:id)[:id]
            end

            # Used to save and respond to all model requests
            def save_and_respond(model, opts = {})
                yield if model.save! && block_given?
                render json: model, **opts
            end

            # Checking if the user is an administrator
            def check_admin
                user = current_user
                head :forbidden unless user && user.sys_admin
            end

            # Checking if the user is support personnel
            def check_support
                user = current_user
                head :forbidden unless user && (user.support || user.sys_admin)
            end

            def token_invalid
                head :unauthorized
            end

            # current user using doorkeeper
            def current_user
                return @current_user if @current_user
                user = User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
                if user
                  @current_user = user
                else
                  raise UserNotFound.new
                end
            end

            # Grab the reactor details for the current request
            def reactor
                @reactor ||= ::Libuv::Reactor.current
            end
        end
    end
end
