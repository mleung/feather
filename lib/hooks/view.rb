module Hooks
  module View
    class << self
      ##
      # This adds a callback method for the view hook
      def register_view(&block)
        @view_hooks ||= [] 
        @view_hooks << block
      end

      def plugin_views
        plugin_views = []
        unless @view_hooks.nil?
          @view_hooks.each do |hook|
            if Hooks::is_hook_valid?(hook)
              begin
                result = hook.call
                result = [result] if result.is_a?(Hash)
                result.each { |r| plugin_views << r.merge({:plugin => Hooks::get_plugin(hook)}) }
              rescue
              end
            end
          end
        end
        plugin_views
      end
    end
  end
end