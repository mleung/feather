module Admin
  class Settings < Base
    def show
      @settings = Configuration.find_or_create({:id => 1}, {:title => 'My new blog'})
      display @settings
    end
    
    def edit
      @settings = Configuration.first
      display @settings
    end
    
    def update
      @settings = Configuration.first
      @settings.title = params[:title]
      @settings.save
      redirect url(:admin_settings)
    end
  end
end