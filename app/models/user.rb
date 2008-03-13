class User < DataMapper::Base
  property :first_name, :string, :nullable => false
  property :last_name, :string, :nullable => false
  property :login, :string, :nullable => false
  property :email, :string, :nullable => false
  property :password, :string, :nullable => false
  
  validates_format_of :email, :with => :email_address
  validates_presence_of :first_name, :last_name, :login, :email, :password
  validates_confirmation_of :password
  validates_uniqueness_of :login, :email
  
  attr_accessor :password_confirmation
  
end