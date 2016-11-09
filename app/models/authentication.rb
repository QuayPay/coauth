
class Authentication < CouchbaseOrm::Base
    design_document :oauth  # less redundant data with short names
    

    attribute :uid, :provider, :user_id, type: String


    view :by_user_id
    def self.by_user(user)
        by_user_id(key: user.id)
    end

    def self.for_user(user_id)
        by_user_id(key: user_id)
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

    # the before_signup block gives installations the ability to reject
    # signups or modify the user record before any user/auth records are
    # stored. if the block returns false, user signup is rejected.
    def self.before_signup(&block)
        @before_signup = block
    end

    def self.before_signup_block
        (@before_signup) || (Proc.new {|user, provider, auth| true })
    end

    # the after_login block gives installations the ability to perform post
    # login functions, such as syncing user permissions from a remote server
    def self.after_login(&block)
        @after_login = block
    end

    def self.after_login_block
        (@after_login) || (Proc.new {|user, provider, auth|})
    end


    protected


    before_create :generate_id
    def generate_id
        self.id = 'auth-' + self.provider + '-' + self.uid
    end
end
