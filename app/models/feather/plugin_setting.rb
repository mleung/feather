module Feather
  class PluginSetting
    include DataMapper::Resource
  
    property :id, Integer, :key => true, :serial => true
    property :handle, String
    property :value, String
    property :plugin_id, String
    
    # This handles cache expirations for settings being created/updated/deleted
    after(:save, :reload_cache)
    after(:destroy, :reload_cache)
    def reload_cache
      @@cache = nil
      Feather::PluginSetting.cache
    end

    class << self
      # This keeps a cache of the plugin settings
      def cache
        @@cache ||= begin
          cached_settings = {}
          Feather::PluginSetting.all.each do |s|
            cached_settings[s.plugin_id] = {} if cached_settings[s.plugin_id].nil?
            cached_settings[s.plugin_id][s.handle] = s.value
          end
          cached_settings
        end
        @@cache
      end
    
      # This retrieves a value from the cache using the handle and plugin
      def find_by_handle_and_plugin(handle, plugin)
        self.cache[plugin][handle] unless self.cache[plugin].nil?
      end

      # This reads a plugin setting and returns the value
      def read(handle, plugin = Feather::Hooks.get_plugin_by_caller(Feather::Hooks.get_caller))
        # Work out the plugin name (depends on whether we were passed an actual plugin, or just the name)
        plugin_name = (plugin.is_a?(Feather::Plugin) ? plugin.name : plugin)
        # Locate and return the setting
        self.find_by_handle_and_plugin(handle, plugin_name)
      end
    
      # This writes a plugin setting, either overwriting the existing value, or creating it if doesn't yet exist
      def write(handle, value, plugin = Feather::Hooks.get_plugin_by_caller(Feather::Hooks.get_caller))
        # Work out the plugin name (depends on whether we were passed an actual plugin, or just the name)
        plugin_name = (plugin.is_a?(Feather::Plugin) ? plugin.name : plugin)
        # See if we can find a setting for this handle and plugin already
        if self.find_by_handle_and_plugin(handle, plugin_name)
          # If so, lets grab it and set the value
          setting = self.first(:handle => handle, :plugin_id => plugin_name)
          setting.value = value
        else
          # Otherwise, we'll create a new one
          setting = new({:handle => handle, :value => value, :plugin_id => plugin_name})
        end
        # Now let's save the setting
        setting.save
      end
    end
  end
end