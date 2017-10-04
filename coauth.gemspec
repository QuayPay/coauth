$:.push File.expand_path("../lib", __FILE__)

require "coauth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
    s.name        = "coauth"
    s.version     = Coauth::VERSION
    s.summary     = "Authorisation and Authentication"
    s.description = "Log in with multiple social media providers"
    s.authors     = ["Cameron Reeves", "Stephen von Takach"]
    s.homepage    = 'http://bitbucket.org/quaypay/coauth'
    s.email       = 'cam@quaypay.com'

    s.add_dependency "doorkeeper-couchbase"
    s.add_dependency "co-elastic-query", "~> 3.1" # Query builder
    s.add_dependency "email_validator"
    s.add_dependency "omniauth-oauth2"
    s.add_dependency "omniauth-ldap2"
    s.add_dependency "omniauth-saml"
    s.add_dependency "addressable"
    s.add_dependency "omniauth"
    s.add_dependency "scrypt"
    s.add_dependency "jwt"

    s.add_development_dependency "rails", "~> 5.0"

    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
end
