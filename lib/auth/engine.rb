module Auth
    class Engine < ::Rails::Engine
        # couchbase::model looks for index design documents in a particular
        # place. since we can't add our doc to that location, temporarily
        # switch out where it looks for docs, perform an update, and reset
        # the location again.
        config.after_initialize do |app|
            model_conf = Couchbase::Model::Configuration
            temp = model_conf.design_documents_paths
            model_conf.design_documents_paths = [File.expand_path(File.dirname(__FILE__))]
            Auth::Authentication.ensure_design_document!
            User.ensure_design_document!
            OauthStrat.ensure_design_document!
            model_conf.design_documents_paths = temp
        end
    end
end
