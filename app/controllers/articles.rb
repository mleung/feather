class Articles < Application
  # This handles the index (recent articles), or the year/month/day views
  def index
    # Unfortunately, we can't use merb-action-args here because we're using the custom rack handler. Booo.
    @archives = Article.get_archive_hash
    if params[:day]
      @articles = Article.find_by_year_month_day(params[:year], params[:month], params[:day])
    elsif params[:month]
      @articles = Article.find_by_year_month(params[:year], params[:month])
    elsif params[:year]
      @articles = Article.find_by_year(params[:year])
    else
      @articles = Article.find_recent
    end
    display @articles
  end
  
  # This handles the permalink for articles, and is executed using the special permalink Rack handler
  def show
    if @article = Article.find_by_permalink(request.uri.to_s)
      # This will render the article and the request will not process any further
      display @article
    else
      # This will force Rack to pass the request off to the main Merb app, as we didn't find a post for the url
      self.status = 404
    end
  end
end