require 'coauth/engine'
require 'libcouchbase'
require 'doorkeeper'

require File.expand_path("../../app/models/authentication", __FILE__)
require File.expand_path("../../app/models/authority", __FILE__)
require File.expand_path("../../app/models/user", __FILE__)


require File.expand_path("../../app/models/oauth_strat", __FILE__)
#require 'omniauth/strategies/generic_oauth'

require File.expand_path("../../app/models/ldap_strat", __FILE__)
#require 'omniauth/strategies/generic_ldap'
