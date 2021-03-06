require 'auth/engine'

require 'couchbase'
require 'doorkeeper'

# Couchbase helpers we use across applications
require 'couch_utils/ensure_unique'
require 'couch_utils/enum'
require 'couch_utils/has_many'
require 'couch_utils/index'
require 'couch_utils/join'

require 'auth/authentication'
require 'auth/authority'
require 'auth/user'

# require 'open_id/store/couch_store'

require 'auth/oauth_strat'
require 'omniauth/strategies/generic_oauth'

require 'auth/ldap_strat'
require 'omniauth/strategies/generic_ldap'

require 'auth/adfs_strat'
require 'omniauth/strategies/generic_adfs'
