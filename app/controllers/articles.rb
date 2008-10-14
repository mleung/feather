class Articles < Application
  # cache_pages :index, :show

  # This handles the index (recent articles), or the year/month/day views
  def index
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
    # Can't use this with caching at the minute, meaning post-process events are tricky...
    #render_then_call(display(@articles)) { Hooks::Events.after_index_article_request(@articles, request) }
    display @articles
  end

  def show(id)
    @article = Article[id]
    # Can't use this with caching at the minute, meaning post-process events are tricky...
    #render_then_call(display(@article)) { Hooks::Events.after_show_article_request(@article, request) }
    display @article
  end
end
