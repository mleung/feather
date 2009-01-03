module Feather
  class Articles < Application
     # cache_pages :index, :show

    # This handles the index (recent articles), or the year/month/day views
    def index
      @archives = Feather::Article.get_archive_hash
      if params[:day]
        @articles = Feather::Article.find_by_year_month_day(params[:year], params[:month], params[:day])
      elsif params[:month]
        @articles = Feather::Article.find_by_year_month(params[:year], params[:month])
      elsif params[:year]
        @articles = Feather::Article.find_by_year(params[:year])
      else
        @articles = Feather::Article.find_recent
      end
      # Can't use this with caching at the minute, meaning post-process events are tricky...
      #render_then_call(display(@articles)) { Feather::Hooks::Events.after_index_article_request(@articles, request) }
      display @articles
    end

    def show(id)
      @archives = Feather::Article.get_archive_hash
      @article = Feather::Article[id]
      # Can't use this with caching at the minute, meaning post-process events are tricky...
      #render_then_call(display(@article)) { Feather::Hooks::Events.after_show_article_request(@article, request) }
      display @article
    end
  end
end