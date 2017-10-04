# frozen_string_literal: true

require 'coauth/engine'
require 'libcouchbase'
require 'doorkeeper'

require_relative '../app/models/authentication'
require_relative '../app/models/authority'
require_relative '../app/models/user'

require_relative '../app/helpers/current_authority_helper.rb'

require_relative '../app/models/oauth_strat'
require 'omniauth/strategies/generic_oauth'

require_relative '../app/models/ldap_strat'
require 'omniauth/strategies/generic_ldap'

require_relative '../app/models/adfs_strat'
require 'omniauth/strategies/generic_adfs'
