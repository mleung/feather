class Articles < Application
  
  def index
    @articles = Article.all(:limit => 10, :order => 'published_at DESC')
    display @articles
  end
  
  def show
    @article = Article[params[:id]]
    display @article
  end
end