class Article < DataMapper::Base
    property :title, :string, :nullable => false
    property :content, :string, :nullable => false
    property :published_at, :datetime
end