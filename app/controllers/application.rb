class Application < Merb::Controller
  include Merb::AssetsMixin
    
  before :get_settings
  
  def get_settings
    @settings = Configuration.first
  end
  
  def notify(text)
    session[:notifications] = text
  end
  
  def self.include_plugin_views(plugin)
    self._template_roots << [File.join(File.join(File.dirname(plugin), ".."), "views"), :_template_location]
  end
end