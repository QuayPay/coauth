# frozen_string_literal: true

require 'email_validator'
require 'digest/md5'
require 'scrypt'

class User < CouchbaseOrm::Base
    design_document :user


    PUBLIC_DATA = {only: [
        :id, :email_digest, :nickname, :name, :first_name, :last_name,
        :country, :building, :created_at
    ]}


    attribute :name, :email, :phone, :country, :image, :metadata, type: String
    attribute :login_name, :staff_id, :first_name, :last_name, :building, type: String
    attribute :password_digest, :email_digest, type: String
    attribute :created_at, type: Integer, default: lambda { Time.now }
    attribute :deleted, type: Boolean, default: false

    belongs_to :authority

    # find_by_email(authority, email)
    ensure_unique [:authority_id, :email], :email do |authority_id, email|
        "#{authority_id}-#{email.to_s.strip.downcase}"
    end

    # find_by_login_name(login)
    ensure_unique :login_name, presence: false
    ensure_unique :staff_id,   presence: false

    attribute :sys_admin, default: false
    attribute :support,   default: false


    before_save :build_name, if: Proc.new { |model| model.first_name.present? }
    def build_name
        self.name = "#{self.first_name} #{self.last_name}"
    end


    #----------------
    # indexes
    #----------------
    index_view :authority_id
    def self.all
        by_authority_id
    end

    view :is_sys_admin
    def self.find_sys_admins
        is_sys_admin(key: true, stale: false)
    end


    # PASSWORD ENCRYPTION::
    # ---------------------
    attr_reader :password
    validates_confirmation_of :password


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



    # Make reference to the email= function of the model
    alias_method :assign_email, :email=
    def email=(new_email)
        assign_email(new_email)

        # For looking up user pictures without making the email public
        self.email_digest = Digest::MD5.hexdigest(new_email) if new_email
    end


    protected


    # Validations
    validates :email, :email => true
    validates :password, length: { minimum: 6, message: 'must be at least 6 characters' }, allow_blank: true
end

