module MerbAuth
  module Adapter
    module ActiveRecord
      
      def self.included(base)
        # Ensure base is a resource
        raise "Mixin class is not an activerecord class" unless base.ancestors.include?(::ActiveRecord::Base)
        set_model_class_decs!(base)
        
        base.send(:include, Map)
        base.send(:include, InstanceMethods )
        base.send(:include, Common)
        
        
        MA[:single_resource] ||= base.name.snake_case.gsub("::", "__").to_sym
        MA[:plural_resource] ||= MA[:single_resource].to_s.pluralize.to_sym
          
        MA[:user] = base
      end
      
      
      module InstanceMethods
        
        def login=(login_name)
          self[:login] = login_name.downcase unless login_name.nil?
        end
      
      end
      
      
      private 
      def self.set_model_class_decs!(base)
        # base.instance_eval do
        #   # Virtual attribute for the unencrypted password
        #   attr_accessor :password, :password_confirmation
        #   validates_presence_of     :login, :email
        #   validates_presence_of     :password,                   :if => :password_required?
        #   validates_presence_of     :password_confirmation,      :if => :password_required?
        #   validates_length_of       :password, :within => 4..40, :if => :password_required?
        #   validates_confirmation_of :password,                   :if => :password_required?
        #   validates_length_of       :login,    :within => 3..40
        #   validates_length_of       :email,    :within => 3..100
        #   validates_uniqueness_of   :login, :email, :case_sensitive => false
        #   validates_uniqueness_of   :password_reset_key, :if => Proc.new{|m| !m.password_reset_key.nil?}
        #   
        #   
        #   before_save :encrypt_password
        #   before_validation :set_login
        #   before_create :make_activation_code
        #   after_create :send_signup_notification
        # end
      end
      
      module DefaultModelSetup
        
        def self.included(base)
          base.instance_eval do
            # Virtual attribute for the unencrypted password
            attr_accessor :password, :password_confirmation
            validates_presence_of     :login, :email
            validates_presence_of     :password,                   :if => :password_required?
            validates_presence_of     :password_confirmation,      :if => :password_required?
            validates_length_of       :password, :within => 4..40, :if => :password_required?
            validates_confirmation_of :password,                   :if => :password_required?
            validates_length_of       :login,    :within => 3..40
            validates_length_of       :email,    :within => 3..100
            validates_uniqueness_of   :login, :email, :case_sensitive => false
            validates_uniqueness_of   :password_reset_key, :if => Proc.new{|m| !m.password_reset_key.nil?}


            before_save :encrypt_password
            before_validation :set_login
            before_create :make_activation_code
            after_create :send_signup_notification
          end
        end
      end # DefaultModelSetup
      
    end # ActiveRecord
  end # Adapter
end # MerbAuth