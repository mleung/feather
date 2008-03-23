class Application < Merb::Controller
  include Merb::AssetsMixin
    
  before :get_settings
  
  def get_settings
    @settings = Configuration.first
  end
  
  def notify(text)
    session[:notifications] = text
  end    
  
  def get_archive_hash
    # TODO: don't call this on the admin side.
    counts = Article.find_by_sql("SELECT COUNT(*) as count, #{specific_date_function} FROM articles WHERE published_at IS NOT NULL GROUP BY year, month ORDER BY year DESC, month DESC")
    @archives = counts.map do |entry|
      {
        :name => "#{Date::MONTHNAMES[entry.month.to_i]} #{entry.year}",
        :month => entry.month.to_i,
        :year => entry.year.to_i,
        :article_count => entry.count
      }
    end
  end
  
  private 
    # Think about moving this somewhere else.
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