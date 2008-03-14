class Articles < Application
  
  def index
    @articles = Article.all
    @settings = Configuration.first
    display @articles
  end
  
  def show
    @article = Article[params[:id]]
    display @article
  end
end