require 'radix'
#
# This disables the built in generator
# => Faster then running validations twice
#
module Couchbase
    class Model
          class UUID
              def initialize(*args)
                  
              end
            
              def next(*args)
                  nil
              end
          end
    end
end


#
# This is our id generator, runs in the before save call back
#
module CouchHelp
    
    # incr, decr, append, prepend == atomic
    # 
    module IdGenerator
        
        B65 = Radix::Base.new(Radix::BASE::B62 + ['-', '_', '~'])
        B10 = Radix::Base.new(10)
        
        def self.included(base)
            base.class_eval do
                
                @@class_id_generator = proc do |name, cluster_id, count|
                    id = Radix.convert(cluster_id, B10, B65) + Radix.convert(count, B10, B65)
                    "#{name}-#{id}"
                end
                
                #
                # Best case we have 18446744073709551615 * 18446744073709551615 model entries for each database cluster
                #  and we can always change the cluster id if this limit is reached
                #
                define_model_callbacks :save, :create
                before_save :generate_id
                before_create :generate_id
                
                def generate_id
                    if self.id.nil?
                        name = "#{self.class.name.underscore}"        # The included classes name
                        cluster = ENV['COUCHBASE_CLUSTER'] || 1        # Cluster ID number
                        
                        
                        #
                        # Generate the id (incrementing values as required)
                        #
                        count = self.class.bucket.incr("#{name}:#{cluster}:count", :create => true)        # This classes current id count
                        self.id = @@class_id_generator.call(name, cluster, count)
                    end
                end
                
                #
                # Override the default hashing function
                #
                def self.set_class_id_generator(&block)
                    @@class_id_generator = block
                end
                
                
            end # END:: class_eval
        end # END:: included
        
    end # END:: IdGenerator
end