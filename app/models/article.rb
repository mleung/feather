class Article < DataMapper::Base
  class << self
    include Merb::ArticlesHelper
  end
  
  property :title, :string, :nullable => false
  property :content, :string, :nullable => false
  property :created_at, :datetime
  property :published_at, :datetime
  property :user_id, :integer, :nullable => false
  validates_presence_of :title, :content, :user_id
  
  belongs_to :user
  
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
  
  def self.find_by_year_month_day_post(year, month, day, post)
    month = Padding::pad_single_digit(month)
    day = Padding::pad_single_digit(day)
    self.all(:published_at.like => "#{year}-#{month}-#{day}%", :title => post)
  end
end