module Hooks
  module Menu
    class << self
      ##
      # This adds the specified menu items for the calling plugin
      def add_menu_item(text, url)
        @menu_item_hooks ||= {}
        raise "Unable to add menu item for unrecognized plugin! (#{location_of_caller[0]})" if (plugin = Hooks::get_plugin_by_caller(location_of_caller[0])).nil?
        @menu_item_hooks[plugin.id] ||= []
        @menu_item_hooks[plugin.id] << {:text => text, :url => url}
      end

      ##
      # This returns the menu items for any plugins that have used the above call
      def menu_items
        menu_items = []
        unless @menu_item_hooks.nil?
          Plugin.all(:active => true).each do |plugin|
            @menu_item_hooks[plugin.id].each { |item| menu_items << item } unless @menu_item_hooks[plugin.id].nil? || @menu_item_hooks[plugin.id].empty?
          end
        end
        menu_items
      end
      
      ##
      # This removes any plugin hooks for the plugin with the specified id
      def remove_plugin_hooks(id)
        @menu_item_hooks.delete(id)
      end
    end
  end
end