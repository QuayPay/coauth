require "auth/engine"

require 'couchbase'
require "doorkeeper"
require "open_id/store/couch_store"
require "omniauth-identity"
require "omniauth-twitter"
require "omniauth-facebook"
require "omniauth-openid"
require "auth/authentication"

# old_docs = ::Couchbase::Model::Configuration.design_documents_paths
# ::Couchbase::Model::Configuration.design_documents_paths = [File.expand_path(File.join(File.expand_path("../", __FILE__), 'auth'))]

# ::Auth::Authentication.ensure_design_document!
# ::Couchbase::Model::Configuration.design_documents_paths = old_docs
