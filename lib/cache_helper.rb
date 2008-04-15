module CacheHelper
  def expire_index
    expire_page(:controller => '/', :action => "index")
  end
  
  def expire_article(article)
    # If an article is a draft, it
    # will not have a permalink to split on.
    unless article.permalink.nil?
      parts = article.permalink.split("/")
      # Expire the year. 
      expire_page(:controller => "/", :action => parts[1])
      # Expire the months
      expire_page(:controller => "/", :action => "#{parts[1]}/#{parts[2]}")
      expire_page(:controller => '/', :action => article.permalink)
    end
  end
  
end