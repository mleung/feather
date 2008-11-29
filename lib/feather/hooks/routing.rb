module Feather
  module Hooks
    module Routing
      class << self
        ##
        # Route registration

        ##
        # This registers a routing block
        def register_route(&block)
          @routes = [] if @routes.nil?
          @routes << block
        end

        ##
        # This calls each individual routing block and passes in the router to run against
        def load_routes(router)
          return if @routes.nil? || @routes.empty?
          @routes.each do |block|
            block.call(router)
          end
        end
      end
    end
  end
end