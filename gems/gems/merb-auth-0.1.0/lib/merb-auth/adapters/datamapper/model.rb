module MerbAuth
  module Adapter
    module DataMapper
      
      def self.included(base)
        # Ensure base is a resource
        base.send(:include, ::DataMapper::Resource) unless ::DataMapper::Resource > base
        
        # Setup the properties for the model
        set_model_class_decs!(base)
        base.send(:include, Map)
        base.send(:include, InstanceMethods )
        base.send(:include, Common)
        
        MA[:single_resource] ||= base.name.snake_case.gsub("::", "__").to_sym
        MA[:plural_resource] ||= MA[:single_resource].to_s.pluralize.to_sym
          
        MA[:user] = base
      end
      
      module InstanceMethods
        
      end # InstanceMethods

      private 
      def self.set_model_class_decs!(base)
        base.class_eval do
          # Sets the login to a downcased version
          def login=(value)
            attribute_set(:login, value.downcase) unless value.nil?
          end
          
        end  
      end # self.set_model_class_decs!
      
      module DefaultModelSetup
        
        def self.included(base)
          base.class_eval do
            attr_accessor :password, :password_confirmation

            property :id,                         Integer,  :serial   => true
            property :login,                      String,   :nullable => false, :length => 3..40, :unique => true
            property :email,                      String,   :nullable => false, :unique => true
            property :created_at,                 DateTime
            property :updated_at,                 DateTime
            property :activated_at,               DateTime
            property :activation_code,            String
            property :crypted_password,           String
            property :salt,                       String
            property :remember_token_expires_at,  DateTime
            property :remember_token,             String
            property :password_reset_key,         String, :writer => :protected

            validates_is_unique :password_reset_key, :if => Proc.new{|m| !m.password_reset_key.nil?}
            validates_present        :password, :if => proc{|m| m.password_required?}
            validates_is_confirmed   :password, :if => proc{|m| m.password_required?}

            before :valid? do
              set_login
            end

            before :save,   :encrypt_password
            before :create, :make_activation_code
            after  :create, :send_signup_notification
          end
        end
      end # DefaultModelSetup     
      
    end # DataMapper
  end # Adapter
end