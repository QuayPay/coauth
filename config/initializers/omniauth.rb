require 'omniauth'
require 'uv-rays'
require 'faraday/adapter/libuv'
Faraday.default_adapter = :libuv

OmniAuth.config.logger = Rails.logger
Rails.application.config.session_store :cookie_store, key: '_coauth_session'

::CoauthAuthConfig = proc {
    provider :developer unless Rails.env.production?
    provider :generic_adfs,  name: 'adfs'
    provider :generic_ldap,  name: 'ldap'
    provider :generic_oauth, name: 'oauth2'
}
