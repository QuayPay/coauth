class Charge < Couchbase::Model

	 include CouchHelp::IdGenerator	
    attribute :amount, :card_id, :paid, :user_id, :merchant
end
