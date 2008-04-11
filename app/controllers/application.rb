class Application < Merb::Controller
  include Merb::AssetsMixin
    
  before :get_settings
  before :load_plugins
  
  def get_settings
    @settings = Configuration.first
  end
  
  ##
  # This ensures all plugins are loaded before any requests are dealt with - if one of the other server processes in a cluster adds one, it needs to be picked up
  def load_plugins
    Plugin.all.each do |plugin|
      plugin.load unless plugin.loaded?
    end
  end
  
  def notify(text)
    session[:notifications] = text
  end
  
  def self.include_plugin_views(plugin)
    self._template_roots << [File.join(File.join(File.dirname(plugin), ".."), "views"), :_template_location]
  end
end