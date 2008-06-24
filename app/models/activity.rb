class Activity
  include DataMapper::Validate
  include DataMapper::Resource
  
  property :id, Integer, :key => true, :serial => true
  property :message, String, :length => 255
  property :created_at, DateTime
  
  validates_present :message, :key => "uniq_msg"

end
