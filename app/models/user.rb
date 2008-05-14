require 'digest/sha1'
begin
  require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
rescue 
  nil
end
class User

  include DataMapper::Resource
  include DataMapper::Validate
  include AuthenticatedSystem::Model

  attr_accessor :password, :password_confirmation

  property :id, Integer, :key => true
  property :login,                      String
  property :email,                      String, :length => 255
  property :crypted_password,           String
  property :salt,                       String
  property :remember_token_expires_at,  DateTime
  property :remember_token,             String
  property :time_zone,                  String
  property :created_at,                 DateTime
  property :updated_at,                 DateTime
  property :name,                       String
  property :default_formatter,          String

  validates_length            :login,                   :within => 3..40
  validates_is_unique         :login
  validates_present           :password,                :if => proc {password_required?}
  validates_present           :password_confirmation,   :if => proc {password_required?}
  validates_length            :password,                :within => 4..40, :if => proc {password_required?}
  validates_is_confirmed      :password,                :groups => :create
  validates_present           :email

  before :save, :encrypt_password

  after :save, :set_create_activity
  after :save, :set_update_activity

  def set_create_activity
    if new_record?
      a = Activity.new
      a.message = "User \"#{self.login}\" created"
      a.save
    end
  end

  def set_update_activity
    unless new_record?
      a = Activity.new
      a.message = "User \"#{self.login}\" updated"
      a.save
    end
  end

  def login=(value);
    attribute_set :login, value.downcase unless value.nil?
  end
end