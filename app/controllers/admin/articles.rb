module Admin
  class Articles < Base
    before :find_article, :only => %w(edit update delete show)

    def index
      @articles = Article.paginate(:page => params[:page], :per_page => 10, :order => [:created_at.desc])
      display @articles
    end
    
    def show
      display @article
    end
    
    def new
      @article = Article.new
      display @article
    end
    
    def create(article)
      @article = Article.new(article)
      @article.user_id = self.current_user.id
      if @article.save
        # Expire the article index to reflect the newly published article
        expire_index if @article.published
        render_then_call(redirect(url(:admin_articles))) do
          # Call events after the redirect
          Hooks::Events.after_publish_article_request(@article, request) if @article.published?
          Hooks::Events.after_create_article_request(@article, request)
        end
      else
        render :new
      end
    end
    
    def edit
      display @article
    end
    
    def update(article)
      if @article.update_attributes(article)
        # Expire the index and article to reflect the updated article
        expire_index
        expire_article(@article)
        render_then_call(redirect(url(:admin_article, @article))) do
          # Call events after the redirect
          Hooks::Events.after_publish_article_request(@article, request) if @article.published?
          Hooks::Events.after_update_article_request(@article, request)
        end
      else
        render :edit
      end
    end
    
    def delete
      @article.destroy
      # Expire the index and article to reflect the removal of the article
      expire_index
      expire_article(@article)
      redirect url(:admin_articles)
    end
    
    private
      def find_article
        @article = Article[params[:id]]
      end
  end
end
