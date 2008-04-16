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
        expire_all_pages if Hooks::View.has_views_registered?(@plugin)
        redirect url(:admin_plugin, @plugin)
      else
        render :new
      end
    end
    
    def update(id)
      #merb-action-args doesn't appear to play nice with ajax calls, so we're using params for the plugin active flag
      @plugin = Plugin[id]
      @plugin.active = (params[:active] == "true" ? true : false) if params[:active]
      @plugin.save
      expire_all_pages if Hooks::View.has_views_registered?(@plugin)
      render_js
    end
    
    def delete(id)
      @plugin = Plugin[id]
      @plugin.destroy!
      redirect url(:admin_plugins)
    end
  end
end