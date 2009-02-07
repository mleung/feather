module Feather
  class Article  
    include DataMapper::Resource
    include DataMapper::Validate
    
    is_paginated
  
    property :id, Integer, :key => true, :serial => true
    property :title, String, :nullable => false, :length => 255
    property :content, Text, :nullable => false
    property :created_at, DateTime
    property :published_at, DateTime
    property :user_id, Integer, :nullable => false
    property :permalink, String, :length => 255
    property :published, Boolean, :default => true
    property :formatter, String, :default => "default"
  
    validates_present :title, :key => "uniq_title"
    validates_present :content, :key => "uniq_content"
    validates_present :user_id, :key => "uniq_user_id"
  
    belongs_to :user
  
    # Core filters
    before :save, :set_published_permalink
    after :create, :set_create_activity
    after :update, :set_update_activity
  
    # Event hooks for plugins
    before :create, :fire_before_create_event
    before :update, :fire_before_update_event
    before :save, :fire_before_save_event
    after :create, :fire_after_create_event
    after :update, :fire_after_update_event
    after :save, :fire_after_save_event
    after :save, :reload_cache
    
    def reload_cache
      Feather::Article.expire_routing
      Feather::Article.routing
      Feather::Article.expire_article_index_page
      Feather::Article.expire_article_page(self.id)
    end
  
    ##
    # This sets the published date and permalink when an article is published
    def set_published_permalink
      # Check to see if we are publishing
      if self.published?
        # Set the date, only if we haven't already
        self.published_at ||= Time.now
      
        # Set the permalink, only if we haven't already
        self.permalink = create_permalink
      else
        self.published_at = self.permalink = nil
      end
      true
    end

    def set_create_activity
      a = Feather::Activity.new
      a.message = "Article \"#{self.title}\" created"
      a.save
    end

    def set_update_activity
      a = Feather::Activity.new
      a.message = "Article \"#{self.title}\" updated"
      a.save
    end

    def fire_before_create_event
      Feather::Hooks::Events.before_create_article(self)
    end

    def fire_before_update_event
      Feather::Hooks::Events.before_update_article(self) unless new_record?
    end

    def fire_before_save_event
      Feather::Hooks::Events.before_save_article(self)
      Feather::Hooks::Events.before_publish_article(self) if self.published?
    end

    def fire_after_create_event
      Feather::Hooks::Events.after_create_article(self)
    end
  
    def fire_after_update_event
      Feather::Hooks::Events.after_update_article(self) unless new_record?
    end

    def fire_after_save_event
      Feather::Hooks::Events.after_save_article(self)
      Feather::Hooks::Events.after_publish_article(self) if self.published?
    end

    def published=(binary_string)
      # We need this because the values get populated from the params
      attribute_set(:published, binary_string == "1")
    end
  
    def create_permalink
      permalink = Feather::Configuration.current.permalink_format.gsub(/:year/,self.published_at.year.to_s)
      permalink.gsub!(/:month/, Feather::Padding::pad_single_digit(self.published_at.month))
      permalink.gsub!(/:day/, Feather::Padding::pad_single_digit(self.published_at.day))
    
      title = self.title.gsub(/\W+/, ' ') # all non-word chars to spaces
      title.strip!            # ohh la la
      title.downcase!         #
      title.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
      permalink.gsub!(/:title/,title)
    
      permalink
    end
    
    def user_name
      self.user.nil? ? "unknown" : self.user.name
    end

    class << self
      # This expires the pages for all of the individual article pages, along with the index
      def expire_article_index_page
        Merb::Cache[:feather].delete Feather::Articles.name
      end
      
      # Expire this specific article page
      def expire_article_page(id)
        Merb::Cache[:feather].delete "#{Feather::Articles.name}/#{id}"
      end
      
      # Expire all of the article pages
      def expire_article_pages
        Feather::Article.all.each { |article| expire_article_page(article.id) }
      end
      
      # This expires the routing mappings
      def expire_routing
        Merb::Cache[:feather].delete "#{Feather::Article.name}::Routing"
      end
      
      # A mapping of ID's to permalinks for the router
      def routing
        Merb::Cache[:feather].fetch "#{Feather::Article.name}::Routing" do
          routing = {}
          Feather::Article.all.each { |a| routing[a.permalink] = a.id }
          routing
        end
      end
      
      ##
      # Custom finders

      def find_recent
        self.all(:published => true, :limit => 10, :order => [:published_at.desc])
      end

      def find_by_year(year)
        self.all(:published_at.like => "#{year}%", :published => true, :order => [:published_at.desc])
      end

      def find_by_year_month(year, month)
        month = Feather::Padding::pad_single_digit(month)
        self.all(:published_at.like => "#{year}-#{month}%", :published => true, :order => [:published_at.desc])
      end

      def find_by_year_month_day(year, month, day)
        month = Feather::Padding::pad_single_digit(month)
        day = Feather::Padding::pad_single_digit(day)
        self.all(:published_at.like => "#{year}-#{month}-#{day}%", :published => true, :order => [:published_at.desc])
      end

      def find_by_permalink(permalink)
        Merb.logger.debug!("permalink: #{permalink}")
        self.first(:permalink => permalink)
      end

      def get_archive_hash
        counts = repository.adapter.query("SELECT COUNT(*) as count, #{specific_date_function} FROM feather_articles WHERE published_at IS NOT NULL AND (published = 'true' OR published = 't' OR published = 1) GROUP BY year, month ORDER BY year DESC, month DESC")
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
          if Merb::Orms::DataMapper.config[:adapter] == "sqlite3"
            "strftime('%Y', published_at) as year, strftime('%m', published_at) as month"
          else
            "extract(year from published_at) as year, extract(month from published_at) as month"
          end
        end
    end
  end
end