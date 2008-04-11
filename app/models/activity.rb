class Activity < DataMapper::Base
  property :message, :string, :nullable => false, :length => 255
  property :created_at, :datetime
end