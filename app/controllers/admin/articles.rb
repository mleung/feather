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
      save_article
      redirect url(:admin_article, @article)
    end
    
    def edit
      @article = Article[params[:id]]
      display @article
    end
    
    def update
      @article = Article[params[:id]]
      save_article
      redirect url(:admin_article, @article)
    end

    private
      def save_article
        @article.attributes = params[:article]
        @article.published_at = Time.now
        @article.save
      end
  end
  
end