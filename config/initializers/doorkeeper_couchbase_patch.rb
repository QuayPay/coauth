# frozen_string_literal: true

# Patch doorkeeper-couchbase to support client_credentials flow
# The gem requires resource_owner_id, but client_credentials doesn't have one
Rails.application.config.after_initialize do
  Doorkeeper::AccessToken.class_eval do
    # Remove the strict presence validation for resource_owner_id
    _validators.reject! { |key, _| key == :resource_owner_id }
    _validate_callbacks.each do |callback|
      if callback.filter.is_a?(ActiveModel::Validations::PresenceValidator)
        callback.filter.attributes.delete(:resource_owner_id)
      end
    end

    # Re-add validation that allows nil resource_owner_id (for client_credentials)
    validates :application, :expires_in, :token, presence: true
  end
end
