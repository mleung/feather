module MerbAuth
  module Adapter
    module ActiveRecord
      module Map
        
        def self.included(base)
          base.send(:include, InstanceMethods)
          base.send(:extend,  ClassMethods)
        end
      
        module InstanceMethods
        end
        
        module ClassMethods
          def find_active_with_conditions(conditions)
            if MA[:user].instance_methods.include?("activated_at")
              MA[:user].with_scope(:find => {:conditions => "activated_at IS NOT NULL"}) do
                MA[:user].find(:first, :conditions => conditions)
              end
            else
              MA[:user].find(:first, :conditions => conditions)
            end
          end  

          def find_with_conditions(conditions)
            MA[:user].find(:first, :conditions => conditions)
          end

          def find_all_with_login_like(login)
            MA[:user].with_scope(:find => {:order => "login DESC", :limit => 1}) do
              MA[:user].find(:all, :conditions => ["login LIKE ?", login])
            end
          end

          # A method to assist with specs
          def clear_database_table
            MA[:user].delete_all
          end
      end
      
      end # Map
    end # ActiveRecord
  end # Adapter
end # MerbAuthenticaiton