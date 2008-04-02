module Hooks
  module Events
    class << self
      ##
      # This registers a block against an event
      def register_event(event, &block)
        @events = {} if @events.nil?
        @events[event] = [] if @events[event].nil?
        @events[event] << block
      end

      ##
      # This calls the event handlers for the specified event
      def run_event(event, *args)
        unless @events.nil?
          @events[event].each do |hook|
            if Hooks::is_hook_valid?(hook)
              begin
                hook.call args
              rescue
              end
            end
          end
        end
      end
      
      ##
      # This calls any event handlers for the before_create_post event
      def before_create_post(post)
        run_event(:before_create_post, post)
      end

      ##
      # This calls any event handlers for the after_create_post event
      def after_create_post(post)
        run_event(:after_create_post, post)
      end
      
      ##
      # This calls any event handlers for the before_update_post event
      def before_update_post(post)
        run_event(:before_update_post, post)
      end

      ##
      # This calls any event handlers for the after_update_post event
      def after_update_post(post)
        run_event(:after_update_post, post)
      end
      
      ##
      # This calls any event handlers for the after_publish_post event
      def after_publish_post(post)
        run_event(:after_publish_post, post)
      end
    end
  end
end