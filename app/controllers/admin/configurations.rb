module Admin
  class Configurations < Base

    before :find_or_create_configuration
    
    def show
      display @configuration
    end
    
    def update
      @configuration.title = params[:title] unless params[:title].nil?
      @configuration.tag_line = params[:tag_line] unless params[:tag_line].nil?
      @configuration.about = params[:about] unless params[:about].nil?
      @configuration.save
      render_js
    end

    private
      def find_or_create_configuration
        @configuration = Configuration.find_or_create({:id => 1}, {:title => "My new blog", :tag_line => "My blog rocks!", :about => "I rock, and so does my blog"})
      end
  end
end