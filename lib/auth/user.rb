require 'email_validator'
require 'digest/md5'


class User < Couchbase::Model
    design_document :user
    include ::CouchbaseId::Generator


    PUBLIC_DATA = {only: [:id, :email_digest, :nickname, :name, :created_at]}


    attribute :name, :email, :phone, :country, :image, :metadata
    attribute :password_digest, :email_digest
    attribute :created_at,  default: lambda { Time.now.to_i }


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
        if ::SCrypt::Password.new(password_digest || '') == unencrypted_password
            self
        else
            false
        end
    rescue ::SCrypt::Errors::InvalidHash
      # accounts created with social logins will have an empty password_digest
      # which causes SCrypt to raise an InvalidHash exception
      false
    end

    # Encrypts the password into the password_digest attribute.
    def password=(unencrypted_password)
        @password = unencrypted_password
        unless unencrypted_password.empty?
            self.password_digest = ::SCrypt::Password.create(unencrypted_password)
        end
    end
    # --------------------
    # END PASSWORD METHODS


    def email=(new_email)
        # in case email isn't supplied on auth
        new_email = '' if new_email.nil?

        @old_email ||= self.attributes[:email] || true
        new_email.strip!     # ! methods return nil if not altered
        new_email.downcase!
        self.attributes[:email] = new_email

        # For looking up user pictures without making the email public
        self.email_digest = Digest::MD5.hexdigest(new_email)
    end

    def self.find_by_email(email)
        id = User.bucket.get("useremail-#{email.downcase}", {quiet: true})
        User.find_by_id(id) if id
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

    after_save :update_email
    def update_email
        if @old_email && @old_email != self.email
            bucket = User.bucket
            bucket.delete("useremail-#{@old_email}", {quiet: true}) unless @old_email == true
            bucket.set("useremail-#{self.email}", self.id)
        end
        @old_email = nil
    end

    before_delete :delete_email_key
    def delete_email_key
        User.bucket.delete("useremail-#{self.email}")
    end
end

