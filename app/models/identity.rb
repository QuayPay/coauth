class Identity < Couchbase::Model
     include OmniAuth::Identity::Model
     include OmniAuth::Identity::SecurePassword
    before_create :generate_id
    has_secure_password
    
    attribute :name, :email, :password_digest

    validates :email, :presence => true

    def self.auth_key=(key)
      super
     if self.find_by_id(self[key.downcase.to_sym])
         raise ActiveRecord::StatementInvalid
     end
    end
    def self.locate(search_hash)
        self.find_by_id(search_hash['email'])
    end
    protected

    def self.validates_uniqueness_of(key, options)
        self.find_by_id(self[key.downcase.to_sym])

    end
    def generate_id
        self.id = self.email.downcase
    end
end
