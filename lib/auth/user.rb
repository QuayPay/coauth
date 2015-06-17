require 'email_validator'
require 'digest/md5'
require 'scrypt'


class User < Couchbase::Model
    design_document :user
    include ::CouchbaseId::Generator
    include ActiveModel::Dirty

    extend EnsureUnique


    PUBLIC_DATA = {only: [:id, :email_digest, :nickname, :name, :created_at]}


    attribute :name, :email, :phone, :country, :image, :metadata
    attribute :password_digest, :email_digest
    attribute :created_at,  default: lambda { Time.now.to_i }
    belongs_to :authority


    ensure_unique [:authority_id, :email], :email do |(authority_id, email)|
        "#{authority_id}-#{email.to_s.strip.downcase}"
    end


    #----------------
    # indexes
    #----------------
    index_view :authority_id

    def self.all
        by_authority_id(stale: false)
    end


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



    alias_method :assign_email, :email=
    def email=(new_email)
        assign_email(new_email)

        # For looking up user pictures without making the email public
        self.email_digest = Digest::MD5.hexdigest(new_email) if new_email
    end


    protected


    # Validations
    validates :email,   :email => true
    validates :password, length: { minimum: 6, message: 'must be at least 6 characters' }, allow_blank: true
end

