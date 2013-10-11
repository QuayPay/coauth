class User < Couchbase::Model
    include OmniAuth::Identity::Model
     include OmniAuth::Identity::SecurePassword
    include CouchHelp::IdGenerator
    attribute   :name, :email, :password_digest, :guest, :image
    

    def self.auth_key=(key)
    super
    if self.find_by_id(self[key.downcase.to_sym])
        raise ActiveRecord::StatementInvalid
    end
    end

    def self.locate(search_hash)
        self.find_by_id(search_hash)
    end

    protected

    def self.validates_uniqueness_of(key, options)
        self.find_by_id(self[key.downcase.to_sym])

    end

    def self.create_with_omniauth(info)
        user = self.new()
        user.name = info['name']
        user.email = info['email']
        user.create!
    end

end

