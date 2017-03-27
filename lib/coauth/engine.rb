# frozen_string_literal: true

module Coauth
    class Engine < ::Rails::Engine
        config.before_initialize do |app|
            # Authentication stack is different
            app.config.middleware.insert_after Rack::Runtime, SelectiveStack
        end
    end
end
