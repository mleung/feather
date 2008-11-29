require File.join(File.dirname(__FILE__), "hooks", "menu")
require File.join(File.dirname(__FILE__), "hooks", "view")
require File.join(File.dirname(__FILE__), "hooks", "events")
require File.join(File.dirname(__FILE__), "hooks", "formatters")
require File.join(File.dirname(__FILE__), "hooks", "routing")

module Feather
  module Hooks
    class << self
      ##
      # This returns true if the hook is within a plugin that is active, false otherwise
      def is_hook_valid?(hook)
        plugin = get_plugin(hook)
        !plugin.nil? && plugin.active
      end

      ##
      # This returns the plugin applicable for any given hook
      def get_plugin(hook)
        get_plugin_by_caller(eval("__FILE__", hook.binding))
      end

      ##
      # This returns the plugin applicable for the specified file
      def get_plugin_by_caller(file)
        Feather::Plugin.all.each do |plugin|
          return plugin if file[0..plugin.path.length - 1] == plugin.path
        end
        nil
      end

      ##
      # This removes all hooks for the specified plugin
      def remove_plugin_hooks(id)
        Feather::Hooks::Menu.remove_plugin_hooks(id)
        Feather::Hooks::View.remove_plugin_hooks(id)
      end

      ##
      # This returns the calling file that called the method that then called this helper method
      def get_caller
        caller[1].split(":")[0]
      end
    end
  end
end