$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "auth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "coauth"
  s.version     = Auth::VERSION
  s.date        = '2013-09-24'
  s.summary     = "Log in with multiple social media providers"
  s.description = "Log in with multiple social media providers"
  s.authors     = ["Cameron Reeves", "Stephen von Takach"]
  s.email       = 'cam@quaypay.com'
  s.homepage    = 'http://bitbucket.org/quaypay/coauth'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "fog"
  s.add_dependency "omniauth-identity"
  s.add_dependency "scrypt"
  s.add_dependency "email_validator"
  s.add_dependency "addressable"
  s.add_dependency "jwt"
  s.add_dependency "omniauth-oauth2"

  s.add_development_dependency "rails", "~> 4.0.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "konacha"
end
