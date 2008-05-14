module Admin
  class Configurations < Base
    before :find_configuration
    
    def show
      display @configuration
    end
    
    def update
      @configuration.title = params[:title] unless params[:title].nil?
      @configuration.tag_line = params[:tag_line] unless params[:tag_line].nil?
      @configuration.about = params[:about] unless params[:about].nil?
      @configuration.about_formatter = params[:about_formatter] unless params[:about_formatter].nil?
      @configuration.permalink_format = params[:permalink_format] unless params[:permalink_format].nil?
      @configuration.save
      # Expire all pages as the configuration settings affect the overall template
      expire_all_pages
      render_js
    end
    
    private
      def find_configuration
        @configuration = Configuration.current
      end
  end
end