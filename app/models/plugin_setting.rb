class PluginSetting < DataMapper::Base
  property :handle, :string
  property :value, :string
  property :plugin_id, :integer

  class << self
    
    def find_by_handle_and_plugin(handle, plugin)
      find(:first, :conditions => ['handle = ? AND plugin_id = ?', handle, plugin.id])
    end

    def read(handle)
      plugin = Hooks.get_plugin_by_caller(Hooks.get_caller)
      setting = find_by_handle_and_plugin(handle, plugin)
      setting.value if setting
    end
    
    def write(handle, value)
      plugin = Hooks.get_plugin_by_caller(Hooks.get_caller)
      if setting = find_by_handle_and_plugin(handle, plugin)
        setting.value = value
      else
        setting = new({:handle => handle, :value => value, :plugin_id => plugin.id})
      end
      setting.save
    end

  end

end