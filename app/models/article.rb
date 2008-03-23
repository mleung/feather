class Article < DataMapper::Base  
  property :title, :string, :nullable => false
  property :content, :string, :nullable => false
  property :created_at, :datetime
  property :published_at, :datetime
  property :user_id, :integer, :nullable => false
  property :permalink, :string, :nullable => false
  validates_presence_of :title, :content, :user_id
  
  belongs_to :user
  
  before_create :set_permalink
  
  def set_permalink
    self.permalink = "/#{self.published_at.year}/#{Padding::pad_single_digit(self.published_at.month)}/#{Padding::pad_single_digit(self.published_at.day)}/#{self.title.downcase.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  def self.find_recent
    self.all(:published_at.not => nil, :limit => 10, :order => 'published_at DESC')
  end
  
  def self.find_by_year(year)
    self.all(:published_at.like => "#{year}%")
  end
  
  def self.find_by_year_month(year, month)
    month = Padding::pad_single_digit(month)
    self.all(:published_at.like => "#{year}-#{month}%")
  end
  
  def self.find_by_year_month_day(year, month, day)
    month = Padding::pad_single_digit(month)
    day = Padding::pad_single_digit(day)
    self.all(:published_at.like => "#{year}-#{month}-#{day}%")
  end
  
  def self.find_by_permalink(permalink)
    self.first(:permalink => permalink)
  end
end