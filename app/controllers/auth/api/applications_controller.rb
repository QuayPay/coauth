# frozen_string_literal: true

module Auth
    module Api
        class ApplicationsController < Base
            before_action :check_admin
            before_action :find_app, only: [:show, :update, :destroy]


            @@elastic ||= Elastic.new(::Doorkeeper::Application, use_couch_type: true)


            def index
                query = @@elastic.query(params)

                owner_id = params.permit(:owner)[:owner]
                if owner_id
                    query.filter({
                        'doc.owner_id' => [owner_id]
                    })
                end

                query.sort = NAME_SORT_ASC
                query.search_field 'doc.name'

                render json: @@elastic.search(query)
            end

            def show
                render json: @app
            end

            def update
                # We don't want redirect_uri to be updatable as ID is generated from this
                config = safe_params
                config.delete(:redirect_uri)

                # Some older installs have UID as null
                @app.uid = @app.id

                @app.assign_attributes(safe_params)
                save_with_owner_id(@app)
            end

            def create
                app = ::Doorkeeper::Application.new(safe_params)

                # Generate the IDs
                app.id = Digest::MD5.hexdigest app.redirect_uri
                app.uid = app.id

                save_with_owner_id(app)
            end

            def destroy
                @app.destroy
                head :ok
            end


            protected


            APP_PARAMS = [
                :name, :scopes, :redirect_uri, :skip_authorization, :secret, :owner_id
            ]
            def safe_params
                params.permit(APP_PARAMS).to_h
            end

            def find_app
                # Find will raise a 404 (not found) if there is an error
                @app = ::Doorkeeper::Application.find(id)
            end

            def save_with_owner_id(app)
                if app.owner_id
                    save_and_respond app
                else
                    render json: { owner: ["can't be blank"] }, status: :not_acceptable
                end
            end
        end
    end
end
