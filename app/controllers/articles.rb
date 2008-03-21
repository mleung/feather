class Articles < Application
  
  def index
    @articles = Article.find_recent
    display @articles
  end
  
  def show
    @article = Article[params[:id]]
    display @article
  end
end