class Activity < DataMapper::Base
  property :message, :string, :nullable => false
  property :created_at, :datetime
end