module Admin
  class Configurations < Base

    before :find_or_create_configuration
    
    def show
      display @configuration
    end
    
    def edit
      display @configuration
    end
    
    def update
      @configuration.title = params[:title] unless params[:title].nil?
      @configuration.save
      # redirect url(:admin_configurations)
      render_js
    end
    
    private
      def find_or_create_configuration
        @configuration = Configuration.find_or_create({:id => 1}, {:title => 'My new blog'})
      end
  end
end