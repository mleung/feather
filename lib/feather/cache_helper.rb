module Feather
  module CacheHelper
    def expire_index
      expire_page(:controller => '/', :action => "index")
    end

    def expire_article(article)
      # If an article is a draft, it will not have a published_at date to go by.
      unless article.published_at.nil?
        year = article.published_at.year
        month = article.published_at.month
        # We need to show single digit months like 04 so stick a 0 in there.
        month = "0#{month}" if month < 10
        # Expire the year. 
        expire_page(:controller => "/", :action => year)
        # Expire the months
        expire_page(:controller => "/", :action => "#{year}/#{month}")
        expire_page(:controller => '/', :action => article.permalink)
      end
    end
  end
end