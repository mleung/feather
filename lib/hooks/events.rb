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
        unless @events.nil? || @events.empty? || @events[event].nil? || @events[event].empty?
          @events[event].each do |hook|
            if Hooks::is_hook_valid?(hook)
              hook.call args
            end
          end
        end
        true
      end
      
      ##
      # This calls any event handlers for the before_create_article event
      def before_create_article(article)
        run_event(:before_create_article, article)
      end
      
      ##
      # This calls any event handlers for the before_update_article event
      def before_update_article(article)
        run_event(:before_update_article, article)
      end
      
      ##
      # This calls any event handlers for the before_save_article event
      def before_save_article(article)
        run_event(:before_save_article, article)
      end
      
      ##
      # This calls any event handlers for the before_publish_article event
      def before_publish_article(article)
        run_event(:before_publish_article, article)
      end
      
      ##
      # This calls any event handlers for the after_create_article event
      def after_create_article(article)
        run_event(:after_create_article, article)
      end

      ##
      # This calls any event handlers for the after_update_article event
      def after_update_article(article)
        run_event(:after_update_article, article)
      end
      
      ##
      # This calls any event handlers for the after_save_article event
      def after_save_article(article)
        run_event(:after_save_article, article)
      end
      
      ##
      # This calls any event handlers for the after_publish_article event
      def after_publish_article(article)
        run_event(:after_publish_article, article)
      end
      
      ##
      # This calls any event handlers for the application_before event
      def application_before
        run_event(:application_before)
      end
      
      ##
      # This calls any event handlers for the after_article_index event
      def after_article_index(articles)
        run_event(:after_article_index, articles)
      end
      
      ##
      # This calls any event handlers for the after_article_show event
      def after_article_show(article)
        run_event(:after_article_show, article)
      end
    end
  end
end