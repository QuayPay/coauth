require "auth/engine"

require 'couchbase'
require "doorkeeper"
require "couch_help/id_generator"
require "open_id/store/couch_store"
require "omniauth-identity"
require "omniauth-twitter"
require "omniauth-facebook"
require "omniauth-openid"


old_docs = ::Couchbase::Model::Configuration.design_documents_paths
::Couchbase::Model::Configuration.design_documents_paths = [File.expand_path(File.join(File.expand_path("../", __FILE__), 'auth'))]
require "auth/authentication"
::Auth::Authentication.ensure_design_document!
::Couchbase::Model::Configuration.design_documents_paths = old_docs
