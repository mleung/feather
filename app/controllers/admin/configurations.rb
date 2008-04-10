module Admin
  class Configurations < Base
    before :find_or_create_configuration
    
    def show
      if @configuration.nil?
        # This picks up a weird bug whereby when we first create default config, it'll error trying to display it - so we redirect back to this page and it works
        redirect url(:admin_configurations)
      else
        display @configuration
      end
    end
    
    def update
      # The merb-action-args stuff doesn't seem to be working with an ajax call. So we're using 
      # the nasty dirty params hash here.
      @configuration.title = params[:title] unless params[:title].nil?
      @configuration.tag_line = params[:tag_line] unless params[:tag_line].nil?
      @configuration.about = params[:about] unless params[:about].nil?
      @configuration.about_formatter = params[:about_formatter] unless params[:about_formatter].nil?
      @configuration.save
      render_js
    end

    private
      ##
      # This creates default config if there isn't any already, otherwise returns the first config we find
      # Because of a weird error displaying the newly created config, we set @configuration to nil to force a reload (see "show" above)
      def find_or_create_configuration
        if Configuration.count == 0
          Configuration.create(:title => "My new blog", :tag_line => "My blog rocks!", :about => "I rock, and so does my blog", :about_formatter => "default")
          @configuration = nil
        else
          @configuration = Configuration.first
        end
      end
  end
end