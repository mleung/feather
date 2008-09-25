module MerbAuth
  module ForgottenPassword
    module Model
      
      def self.included(base)
        base.send(:extend,  ClassMethods)
        base.send(:include, InstanceMethods)
      end
      
      module ClassMethods
        def make_key
          Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
        end
        
        def authenticate(email, password)
          super(email, password)
          return if @u.nil?
          return @u unless @u.has_forgotten_password?
          @u.clear_forgot_password!
          puts @u.inspect
          @u
        end
      end
      
      module InstanceMethods
        def forgot_password! # Must be a unique password key before it goes in the database
          pwreset_key_success = false
          until pwreset_key_success
            self.password_reset_key = self.class.make_key
            self.save
            pwreset_key_success = self.errors.on(:password_reset_key).nil? ? true : false 
          end
          send_forgot_password
        end

        def has_forgotten_password?
          !self.password_reset_key.nil?
        end

        def clear_forgot_password!
          self.password_reset_key = nil
          self.save
        end
        

      end # InstanceMethods
      
    end 
  end
end

MA[:user].send(:include, MerbAuth::ForgottenPassword::Model)