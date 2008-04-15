module Admin
  class Configurations < Base    
    def show
      @configuration = Configuration.current
      display @configuration
    end
    
    def update
      # The merb-action-args stuff doesn't seem to be working with an ajax call. So we're using 
      # the nasty dirty params hash here.
      @configuration = Configuration.current
      @configuration.title = params[:title] unless params[:title].nil?
      @configuration.tag_line = params[:tag_line] unless params[:tag_line].nil?
      @configuration.about = params[:about] unless params[:about].nil?
      @configuration.about_formatter = params[:about_formatter] unless params[:about_formatter].nil?
      @configuration.save
      # Expire everything! 
      expire_all_pages
      render_js
    end
  end
end