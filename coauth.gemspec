$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "coauth/version"

Gem::Specification.new do |s|
  s.name        = 'coauth'
  s.version     = AppCore::VERSION
  s.date        = '2013-09-24'
  s.summary     = "Log in with multiple social media providers"
  s.description = "Log in with multiple social media providers"
  s.authors     = ["Cameron Reeves", "Stephen von Takach"]
  s.email       = 'cam@quaypay.com'
  s.test_files  = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir["test/**/*"]
  s.homepage    =
    'http://bitbucket.org/quaypay/coauth'

  s.add_dependency "fog"
  s.add_dependency "rails"
  s.add_dependency "omniauth-identity"
  s.add_dependency "omniauth-twitter"
  s.add_dependency "omniauth-facebook"
  s.add_dependency "omniauth-openid"
  s.add_dependency "radix"
  s.add_development_dependency "rspec"
  s.add_development_dependency "konacha"
  s.add_dependency "sextant"
end
