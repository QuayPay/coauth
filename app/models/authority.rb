# frozen_string_literal: true

require 'addressable/uri'

class Authority < CouchbaseOrm::Base
    design_document :sgrp

    attribute :created_at,  type: Integer, default: lambda { Time.now }

    attribute :name,        type: String
    attribute :dom,         type: String
    attribute :description, type: String
    attribute :login_url,   type: String, default: '/login?continue={{url}}'
    attribute :logout_url,  type: String, default: '/'
    attribute :internals,   type: Hash,   default: lambda { {} }
    attribute :config,      type: Hash,   default: lambda { {} }

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

    class << self
        alias_method :find_by_domain, :find_by_dom
    end


    def domain=(dom)
        self[:dom] = self.class.process_dom(dom)
    end

    def as_json(options = {})
        super.tap do |json|
            json[:login_url] = self.login_url
            json[:logout_url] = self.logout_url
        end
    end
end
