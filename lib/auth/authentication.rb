module Auth
    class Authentication < Couchbase::Model
        before_create :generate_id
        

        attribute :uid, :provider, :user_id


        # TODO:: Create this view
        view :by_user_id
        def self.by_user(id)
            by_user_id({:key => [id], :stale => 'false'})
        end

        def self.from_omniauth(auth)
            self.find_by_id('auth-' + auth['provider'] + '-' + auth['uid'])
        end

        def self.create_with_omniauth(auth, user_id)
            authen = self.new
            authen.provider = auth['provider']
            authen.uid = auth['uid']
            authen.user_id = user_id
            authen.create!
        end


        protected

        
        def generate_id
            self.id = 'auth-' + self.provider + '-' + self.uid
        end
    end
end
