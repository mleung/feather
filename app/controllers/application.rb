class Application < Merb::Controller
  include Merb::AssetsMixin
  include CacheHelper

  before :get_settings
  before :load_plugins
  before :fire_before_event

  ##
  # This grabs settings
  def get_settings
    @settings = Configuration.current
  end

  ##
  # This ensures all plugins are loaded before any requests are dealt with - if one of the other server processes in a cluster adds one, it needs to be picked up
  def load_plugins
    Plugin.all(:order => [:name]).each do |plugin|
      plugin.load unless plugin.loaded?
    end
  end

  ##
  # This fires the application before event for any subscribing plugins
  def fire_before_event
    Hooks::Events.application_before
  end

  ##
  # This puts notification text in the session, to be rendered in any view
  def notify(text)
    session[:notifications] = text
  end

  ##
  # This allows a view to expand its template roots to include its own custom views
  def self.include_plugin_views(plugin)
    self._template_roots << [File.join(Hooks::get_plugin_by_caller(plugin).path, "views"), :_template_location]
  end
end