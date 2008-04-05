module Admin
  class Plugins < Base
    def index
      @plugins = Plugin.all
      display @plugins
    end
    
    def show(id)
      @plugin = Plugin[id]
      display @plugin
    end
    
    def new
      @plugin = Plugin.new
      display @plugin
    end
    
    def create(plugin)
      @plugin = Plugin.new
      @plugin.url = plugin[:url]
      if @plugin.save
        redirect url(:admin_plugin, @plugin)
      else
        render :new
      end
    end
    
    def edit(id)
      @plugin = Plugin[id]
      display @plugin
    end
    
    def update(id, plugin)
      @plugin = Plugin[id]
      @plugin.active = (plugin[:active] == "true" ? true : false) if plugin && plugin[:active]
      if @plugin.save
        redirect url(:admin_plugin, @plugin)
      else
        redirect :edit
      end
    end
    
    def delete(id)
      @plugin = Plugin[id]
      @plugin.destroy!
      redirect url(:admin_plugins)
    end
  end
end