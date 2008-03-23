class Article < DataMapper::Base  
  property :title, :string, :nullable => false
  property :content, :string, :nullable => false
  property :created_at, :datetime
  property :published_at, :datetime
  property :user_id, :integer, :nullable => false
  property :permalink, :string, :nullable => false
  property :published, :boolean, :default => false
  validates_presence_of :title, :content, :user_id
  
  belongs_to :user
  
  before_create :set_permalink
  after_create :set_create_activity
  after_update :set_update_activity
  
  def set_permalink
    self.permalink = "/#{self.published_at.year}/#{Padding::pad_single_digit(self.published_at.month)}/#{Padding::pad_single_digit(self.published_at.day)}/#{self.title.downcase.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  def set_create_activity
    a = Activity.new
    a.message = "Article \"#{self.title}\" created"
    a.save
  end
  
  def set_update_activity
    a = Activity.new
    a.message = "Article \"#{self.title}\" updated"
    a.save
  end
  
  class << self
    def find_recent
      self.all(:published => true, :limit => 10, :order => "published_at DESC")
    end
  
    def find_by_year(year)
      self.all(:published_at.like => "#{year}%", :published => true, :order => "published_at DESC")
    end
  
    def find_by_year_month(year, month)
      month = Padding::pad_single_digit(month)
      self.all(:published_at.like => "#{year}-#{month}%", :published => true, :order => "published_at DESC")
    end
  
    def find_by_year_month_day(year, month, day)
      month = Padding::pad_single_digit(month)
      day = Padding::pad_single_digit(day)
      self.all(:published_at.like => "#{year}-#{month}-#{day}%", :published => true, :order => "published_at DESC")
    end
  
    def find_by_permalink(permalink)
      self.first(:permalink => permalink)
    end
    
    def get_archive_hash
      counts = self.find_by_sql("SELECT COUNT(*) as count, #{specific_date_function} FROM articles WHERE published_at IS NOT NULL AND published = 1 GROUP BY year, month ORDER BY year DESC, month DESC")
      archives = counts.map do |entry|
        {
          :name => "#{Date::MONTHNAMES[entry.month.to_i]} #{entry.year}",
          :month => entry.month.to_i,
          :year => entry.year.to_i,
          :article_count => entry.count
        }
      end
      archives
    end

    private 
      def specific_date_function
        # This is pretty nasty loading up the db.yml to get at this, but I wasn't able to 
        # find the method in merb just yet. Change it!
        if YAML::load(File.read("config/database.yml"))[Merb.environment.to_sym][:adapter] == 'sqlite3'
          "strftime('%Y', published_at) as year, strftime('%m', published_at) as month"
        else
          "extract(year from published_at) as year, extract(month from published_at) as month"
        end
      end
  end
end