module Hooks
  module Menu
    class << self
      ##
      # This adds a callback method for the menu item hook
      def add_menu_item(&block)
        @menu_item_hooks = [] if @menu_item_hooks.nil?
        @menu_item_hooks << block
      end

      ##
      # This returns the menu items for any plugins that have used the above hook
      def menu_items
        menu_items = []
        unless @menu_item_hooks.nil?
          @menu_item_hooks.each do |hook|
            if Hooks::is_hook_valid?(hook)
              begin
                menu_items << hook.call
              rescue
              end
            end
          end
        end
        menu_items
      end
    end
  end
end