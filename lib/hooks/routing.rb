module Hooks
  module Routing
    class << self
      ##
      # This adds a callback method for the routing hook
      def add_route(&block)
        @route_hooks = [] if @route_hooks.nil?
        @route_hooks << block
      end

      ##
      # This returns the routes for any plugins that have used the above hook
      def routes
        route_hooks = []
        unless @route_hooks.nil?
          @route_hooks.each do |hook|
            if Hooks::is_hook_valid?(hook)
              begin
                route_hooks << hook.call
              rescue
              end
            end
          end
        end
        route_hooks
      end
    end
  end
end