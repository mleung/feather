module Admin
  class Configurations < Base

    before :find_or_create_configuration, :except => 'update'
    
    def show
      display @configuration
    end
    
    def edit
      display @configuration
    end
    
    def update
      @configuration = Configuration.first
      @configuration.attributes = params[:configuration]
      @configuration.save
      redirect url(:admin_configurations)
    end
    
    private
      def find_or_create_configuration
        @configuration = Configuration.find_or_create({:id => 1}, {:title => 'My new blog'})
      end
  end
end