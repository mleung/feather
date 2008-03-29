module Admin
  class Plugins < Base
    def index
      @plugins = Plugin.all
      display @plugins
    end
    
    def show
      @plugin = Plugin[params[:id]]
      display @plugin
    end
    
    def new
      @plugin = Plugin.new
      display @plugin
    end
    
    def create
      @plugin = Plugin.new
      @plugin.url = params[:plugin][:url]
      if @plugin.save
        redirect url(:admin_plugin, @plugin)
      else
        render :new
      end
    end
    
    def edit
      @plugin = Plugin[params[:id]]
      display @plugin
    end
    
    def update
      @plugin = Plugin[params[:id]]
      @plugin.active = (params[:plugin][:active] == "true" ? true : false) if params[:plugin] && params[:plugin][:active]
      if @plugin.save
        redirect url(:admin_plugin, @plugin)
      else
        redirect :edit
      end
    end
    
    def delete
      @plugin = Plugin[params[:id]]
      @plugin.destroy!
      redirect url(:admin_plugins)
    end
  end
end