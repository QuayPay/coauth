module Coauth
  class Engine < ::Rails::Engine
    config.after_initialize do |app|
        Couchbase::Model::Configuration.design_documents_paths << File.join(File.expand_path("../", __FILE__), '../../app/models/coauth')
    end
  end
end
