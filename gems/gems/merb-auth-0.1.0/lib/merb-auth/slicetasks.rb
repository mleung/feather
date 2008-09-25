namespace :slices do
  namespace :merb_auth do 
    
    # add your own merb_auth tasks here
    
    # implement this to test for structural/code dependencies
    # like certain directories or availability of other files
    desc "Test for any dependencies"
    task :preflight do
    end
    
    # implement this to perform any database related setup steps
    desc "Migrate the database"
    task :migrate do
    end

    desc "Generate Migration"
    task :generate_migration => :merb_env do
      puts `merb-gen ma_migration #{MA[:user].name}`
    end
    
    namespace :ar do
      desc "Print Model Properties"
      task :model_setup do
        out =<<-EOS
        
# -------------------------------------------------------------------
  include MerbAuth::Adapter::ActiveRecord

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
# -------------------------------------------------------------------
EOS
        puts "Enter this into your model to make it usable with MerbAuth by default"
        puts out
        puts "Enter this into your model to make it usable with MerbAuth by default"
      end
      
    end # ar

    namespace :dm do
      desc "Print Model Properties"
      task :model_setup do
        out =<<-EOS

# -------------------------------------------------------------------

  include MerbAuth::Adapter::DataMapper
  
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
  
  # -------------------------------------------------------------------
  EOS
          puts "Enter this into your model to make it usable with MerbAuth by default"
          puts out
          puts "Enter this into your model to make it usable with MerbAuth by default"
  
      end # setup
    end # dm
    
  end # merb_auth
end # slices