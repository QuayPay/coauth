module Auth
    class Authentication < Couchbase::Model
        design_document :oauth  # less redundant data with short names
        before_create :generate_id
        

        attribute :uid, :provider, :user_id


        # TODO:: Create this view
        view :by_user_id
        def self.by_user(user)
            by_user_id(key: user.id, stale: false)
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

        def self.after_login(&block)
            @after_login = block
        end

        def self.after_login_block
            (@after_login) || (Proc.new {|user|})
        end


        protected

        
        def generate_id
            self.id = 'auth-' + self.provider + '-' + self.uid
        end
    end
end
