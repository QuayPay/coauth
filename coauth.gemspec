$:.push File.expand_path("../lib", __FILE__)

require "coauth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
    s.name        = "coauth"
    s.version     = Auth::VERSION
    s.summary     = "Authorisation and Authentication"
    s.description = "Log in with multiple social media providers"
    s.authors     = ["Cameron Reeves", "Stephen von Takach"]
    s.homepage    = 'http://bitbucket.org/quaypay/coauth'
    s.email       = 'cam@quaypay.com'

    s.add_dependency "doorkeeper-couchbase"
    s.add_dependency "email_validator"
    s.add_dependency "addressable"
    s.add_dependency "scrypt"

    s.add_dependency "omniauth-identity"
    s.add_dependency "omniauth-oauth2"
    s.add_dependency "omniauth-ldap"

    s.add_development_dependency "rails", "~> 5.0"

    gem.files         = `git ls-files`.split("\n")
    gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
end
