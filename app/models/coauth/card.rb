	require 'digest'
	require 'scrypt'
	require 'openssl'
	require 'base64'
	require 'fog'
class Card < Couchbase::Model
	before_create :generate_id
	attribute    :cardtype, :carddetails, :name, :lastfour, :user_id, :pkpass

	view :by_user_id, :by_card_no

	

	def self.by_cardno(cardno) 
		by_card_no({:key => [cardno]})
	end

	def self.by_user(id)
		by_user_id({:key => [id], :stale => false})
	end
	
	def generate_id
		salt = '800$8$59$' + Base64.encode64(Digest::SHA1.hexdigest(self.carddetails))[0..-4] # :key_len => 128 (2048bits), :max_time => 0.5 (500ms), :max_mem => 1024 * 1024 * 2 (2mb)
        key = OpenSSL::PKey::RSA.new(4096)
        cipher = OpenSSL::Cipher::Cipher.new('aes256')
        self.pkpass = SCrypt::Engine.hash_secret(OpenSSL::Digest.digest('MD5', key.public_key.to_pem), salt)
        public_key = key.public_key.to_pem(cipher, self.pkpass)
        self.id = SCrypt::Engine.hash_secret(self.carddetails, salt)
        self.carddetails = key.private_encrypt(self.carddetails)

        connection = Fog::Storage.new({
		  :provider                 => 'AWS',
		  :aws_access_key_id        => 'AKIAJ7IM6PPI6CQIZLOA',
		  :aws_secret_access_key    => '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'
		})
		directory = connection.directories.get("quaypay")
				# list directories
		p connection.directories

		# upload that resume
		file = directory.files.create(
		  :key    => self.id + '.pem',
		  :body   => public_key,
		  :public => false
		  )
	end
end
