class Charge < Couchbase::Model

	 include CouchHelp::IdGenerator	
    attribute :amount, :card_id, :paid, :user_id, :merchant

    view :by_user_id


    def self.by_user(id)
		by_user_id({:key => [id], :stale => false})
	end
	

end
