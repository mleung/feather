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
      @article.attributes = params[:article]
      @article.published_at = Time.now
      if @article.save
        redirect url(:admin_article, @article)
      else
        render :new
      end
    end
    
    def edit
      @article = Article[params[:id]]
      display @article
    end
    
    def update
      @article = Article[params[:id]]
      if @article.update_attributes(params[:article])
        redirect url(:admin_article, @article)
      else
        render :edit
      end
    end

  end
  
end