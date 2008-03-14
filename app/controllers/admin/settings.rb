module Admin
  class Settings < Application
  
    # TODO: Think about making a base admin controller and have the layout in there, and have these controllers inherit
    layout :admin
  
    def index
      render
    end
  
  end
end 
