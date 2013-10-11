module Auth
    class Authentication < Couchbase::Model
        before_create :generate_id
        
        attribute :uid, :provider, :user_id
        view :by_user_id
        belongs_to :user
        
        def self.by_user(id)
            by_user_id({:key => [id], :stale => 'false'})
        end

        protected
        
        def self.from_omniauth(auth)
            self.find_by_id("auth-" + auth["provider"] + "::" + auth["uid"])
        end    
        
        def self.create_with_omniauth(auth)
            authen = self.new
            authen.provider = auth['provider']
            authen.uid = auth['uid']
            authen.create!
        end
        
        def generate_id
            self.id = "auth-" + self.provider + "::" + self.uid
        end
    end
end
