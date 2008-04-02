require File.join(File.join(File.dirname(__FILE__), "hooks"), "menu")
require File.join(File.join(File.dirname(__FILE__), "hooks"), "routing")
require File.join(File.join(File.dirname(__FILE__), "hooks"), "view")
require File.join(File.join(File.dirname(__FILE__), "hooks"), "events")

module Hooks
  class << self
    ##
    # This returns true if the hook is within a plugin that is active, false otherwise
    def is_hook_valid?(hook)
      p = get_plugin(hook)
      !p.nil? && p.active
    end
    
    ##
    # This returns the plugin applicable for any given hook
    def get_plugin(hook)
      file = eval("__FILE__", hook.binding)
      Plugin.all.each do |p|
        #TODO: more efficient way to do this?
        return p if file[0..p.path.length - 1] == p.path
      end
      nil
    end
  end
end