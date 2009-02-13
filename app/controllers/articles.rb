module Feather
  class Articles < Application
    # This handles the index (recent articles), or the year/month/day views
    def index
      if params[:day]
        Merb::Cache[:feather].fetch "#{Feather::Articles.name}/#{params[:year]}/#{params[:month]}/#{params[:day]}" do
          @archives = Feather::Article.get_archive_hash
          @articles = Feather::Article.find_by_year_month_day(params[:year], params[:month], params[:day])
          display @articles
        end
      elsif params[:month]
        Merb::Cache[:feather].fetch "#{Feather::Articles.name}/#{params[:year]}/#{params[:month]}" do
          @archives = Feather::Article.get_archive_hash
          @articles = Feather::Article.find_by_year_month(params[:year], params[:month])
          display @articles
        end
      elsif params[:year]
        Merb::Cache[:feather].fetch "#{Feather::Articles.name}/#{params[:year]}" do
          @archives = Feather::Article.get_archive_hash
          @articles = Feather::Article.find_by_year(params[:year])
          display @articles
        end
      else
        Merb::Cache[:feather].fetch Feather::Articles.name do
          @archives = Feather::Article.get_archive_hash
          @articles = Feather::Article.find_recent
          display @articles
        end
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