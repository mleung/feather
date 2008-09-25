module MerbAuth
  module Adapter
    module DataMapper
      module Map
      
        def self.included(base)
          base.send(:include, InstanceMethods)
          base.send(:extend,  ClassMethods)
        end
      
        module InstanceMethods
        end
      
        module ClassMethods
          def find_with_conditions(conditions)
            first(conditions)
          end
        
          def find_all_with_login_like(logn)
            all(:login.like => logn, :order => [:login.desc], :limit => 1)
          end
                  
          def find_active_with_conditions(conditions)
            first(conditions.merge(:activated_at.not => nil))
          end
        
          def clear_database_table
            auto_migrate!
          end
        end # ClassMethods 
        
      end # Map
    end # DataMapper
  end # Adapters
end # MerbAuth