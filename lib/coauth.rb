require 'auth/engine'

require 'couchbase'
require 'doorkeeper'
require 'auth/authentication'
require 'auth/user'


# old_docs = ::Couchbase::Model::Configuration.design_documents_paths
# ::Couchbase::Model::Configuration.design_documents_paths = [File.expand_path(File.join(File.expand_path("../", __FILE__), 'auth'))]

# ::Auth::Authentication.ensure_design_document!
# ::Couchbase::Model::Configuration.design_documents_paths = old_docs
