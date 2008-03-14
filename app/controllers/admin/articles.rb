module Admin
  class Articles < Base
    def index
      @articles = Article.all
      display @articles
    end
    
    def show
      @article = Article[params[:id]]
      display @article
    end
    
    def new
      @article = Article.new
      display @article
    end
    
    def create
      @article = Article.new
      @article.title = params[:title]
      @article.content = params[:content]
      @article.published_at = Time.now
      @article.save
      redirect url(:admin_article, @article)
    end
    
    def edit
      @article = Article[params[:id]]
      display @article
    end
    
    def update
      @article = Article[params[:id]]
      @article.title = params[:title]
      @article.content = params[:content]
      @article.published_at = Time.now
      @article.save
      redirect url(:admin_article, @article)
    end
  end
end