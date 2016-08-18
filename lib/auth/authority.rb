require 'addressable/uri'

class Authority < Couchbase::Model
    include CouchbaseId::Generator
    extend EnsureUnique

    design_document :sgrp

    attribute :created_at, default: lambda { Time.now.to_i }

    attribute :name
    attribute :dom
    attribute :description
    attribute :login_url,  default: '/login?continue={{url}}'
    attribute :logout_url, default: '/'
    attribute :internals,  default: lambda { {} }
    attribute :config,     default: lambda { {} }

    validates :name,   presence: true

    #----------------
    # domain
    #----------------
    # domain is accessed through :domain, but stored in :dom. couchbase model
    # loads models by calling attr= for every attribute, meaning the domain
    # would be parsed by uri each time the authority was loaded if it was
    # stored in :domain.
    ensure_unique :dom do |domain|
        parsed = Addressable::URI.heuristic_parse(domain)
        parsed.nil? || parsed.host.nil? ? nil : parsed.host.downcase
    end

    alias_method :domain, :dom

    def domain=(dom)
        self[:dom] = self.class.process_dom(dom)
    end

    class << self
        alias_method :find_by_domain, :find_by_dom
    end

    def as_json(options = {})
        super.tap do |json|
            json[:login_url] = self.login_url
            json[:logout_url] = self.logout_url
        end
    end
end

module CurrentAuthorityHelper
    def current_authority
        @current_authority ||= Authority.find_by_domain(request.host)
    end
end
