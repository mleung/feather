class Article < DataMapper::Base
  property :title, :string, :nullable => false
  property :content, :string, :nullable => false
  property :created_at, :datetime
  validates_presence_of :title, :content
end