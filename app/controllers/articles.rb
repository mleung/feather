class Articles < Application
  
  def index
    if params[:post]
      @articles = Article.find_by_year_month_day_post(params[:year], params[:month], params[:day], params[:post])
    elsif params[:day]
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
  
  def show
    @article = Article[params[:id]]
    display @article
  end
end