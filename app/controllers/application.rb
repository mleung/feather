class Application < Merb::Controller
  include Merb::AssetsMixin
    
  before :get_settings
  
  def get_settings
    @settings = Configuration.first
  end
  
  def notify(text)
    session[:notifications] = text
  end    
end