module Feather
  class Articles < Application
    # This handles the index (recent articles), or the year/month/day views
    def index
      Merb::Cache[:feather].fetch Feather::Articles.name do
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
        
        display @articles
      end
    end

    def show(id)
      Merb::Cache[:feather].fetch "#{Feather::Articles.name}/#{id}" do
        @archives = Feather::Article.get_archive_hash
        @article = Feather::Article[id]
        
        display @article
      end
    end
  end
end