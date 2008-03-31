module Hooks
  module View
    class << self
      ##
      # This adds a callback method for the view hook
      def register_view(&block)
        Merb.logger.info("register view called")
        @view_hooks ||= [] 
        @view_hooks << block
      end
      
      def plugin_views
        plugin_views = []
        unless @view_hooks.nil?
          @view_hooks.each do |hook|
            begin
              plugin_views << hook.call if Hooks::is_hook_valid?(hook)
            rescue
            end
          end
        end
        plugin_views
      end
      
    end
  end
end