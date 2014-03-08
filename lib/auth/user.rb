
class User < Couchbase::Model
    include ::CouchbaseId::Generator

    attribute :name, :email, :phone, :country, :image
    attribute :password_digest


    # PASSWORD ENCRYPTION::
    # ---------------------
    attr_reader   :password

    validates_confirmation_of :password
    #validates_presence_of     :password_digest   # password optional

    if respond_to?(:attributes_protected_by_default)
        def self.attributes_protected_by_default
            super + ['password_digest']
        end
    end

    def authenticate(unencrypted_password)
        if SCrypt::Password.new(password_digest) == unencrypted_password
            self
        else
            false
        end
    end

    # Encrypts the password into the password_digest attribute.
    def password=(unencrypted_password)
        @password = unencrypted_password
        if unencrypted_password && !unencrypted_password.empty?
            self.password_digest = SCrypt::Password.create(unencrypted_password)
        end
    end
    # --------------------
    # END PASSWORD METHODS
end
