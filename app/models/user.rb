require 'digest/sha1'
begin
  require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
rescue 
  nil
end
class User < DataMapper::Base
  include AuthenticatedSystem::Model
  
  attr_accessor :password, :password_confirmation
  
  property :login,                      :string
  property :email,                      :string
  property :crypted_password,           :string
  property :salt,                       :string
  property :remember_token_expires_at,  :datetime
  property :remember_token,             :string
  property :time_zone,                  :string
  property :created_at,                 :datetime
  property :updated_at,                 :datetime
  property :name,                       :string
  
  validates_length_of         :login,                   :within => 3..40
  validates_uniqueness_of     :login
  validates_presence_of       :password,                :if => proc {password_required?}
  validates_presence_of       :password_confirmation,   :if => proc {password_required?}
  validates_length_of         :password,                :within => 4..40, :if => proc {password_required?}
  validates_confirmation_of   :password,                :groups => :create
    
  before_save :encrypt_password
  
  def login=(value)
    @login = value.downcase unless value.nil?
  end
  
end