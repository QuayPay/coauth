require 'email_validator'
require 'digest/md5'


class User < Couchbase::Model
    include ::CouchbaseId::Generator

    attribute   :name, :email, :phone, :country, :image, :metadata
    attribute   :password_digest, :email_digest


    after_save  :update_email  # for uniqueness check


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


    def email=(new_email)
        new_email = '' if new_email.nil?

        @old_email ||= self.attributes[:email] || true
        new_email.strip! # returns nil if not altered
        self.attributes[:email] = new_email

        # For looking up user pictures without making the email public
        self.email_digest = Digest::MD5.hexdigest(new_email)
    end


    protected


    # Validations
    validates :email,   :presence => true
    validates :email,   :email => true
    validate  :email_unique

    def email_unique
        result = User.bucket.get("useremail-#{self.email}", {quiet: true})
        if result != nil && result != self.id
            errors.add(:email, 'must be unique')
        end
    end

    def update_email
        if @old_email && @old_email != self.email
            User.bucket.delete("useremail-#{@old_email}", {quiet: true}) unless @old_email == true
            User.bucket.set("useremail-#{self.email}", self.id)
        end
        @old_email = nil
    end
end
