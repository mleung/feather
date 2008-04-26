module Hooks
  module Events
    class << self
      ##
      # Event registration

      ##
      # This registers a block against an event
      def register_event(event, &block)
        @events = {} if @events.nil?
        @events[event] = [] if @events[event].nil?
        @events[event] << block
      end

      ##
      # This calls the event handlers for the specified event (wrapping errors)
      def run_event(event, *args)
        unless @events.nil? || @events.empty? || @events[event].nil? || @events[event].empty?
          @events[event].each do |hook|
            if Hooks::is_hook_valid?(hook)
              begin
                hook.call args
              rescue
              end
            end
          end
        end
        true
      end

      ##
      # Model events

      ##
      # This gets called before article creation, and provides the article that is being created
      def before_create_article(article)
        run_event(:before_create_article, article)
      end

      ##
      # This gets called before article updating, and provides the article that is being updated
      def before_update_article(article)
        run_event(:before_update_article, article)
      end

      ##
      # This gets called before an article is saved (created or updated), and provides the article that is being saved
      def before_save_article(article)
        run_event(:before_save_article, article)
      end

      ##
      # This gets called before an article is published, and provides the article that is being published
      def before_publish_article(article)
        run_event(:before_publish_article, article)
      end

      ##
      # This gets called after an article is created, and provides the article that was created
      def after_create_article(article)
        run_event(:after_create_article, article)
      end

      ##
      # This gets called after an article is updated, and provides the article that was updated
      def after_update_article(article)
        run_event(:after_update_article, article)
      end

      ##
      # This gets called after an article is saved, and provides the article that was saved
      def after_save_article(article)
        run_event(:after_save_article, article)
      end

      ##
      # This gets called after an article is published, and provides the article that was published
      def after_publish_article(article)
        run_event(:after_publish_article, article)
      end

      ##
      # Controller events

      ##
      # This gets called before any controller action
      def application_before
        run_event(:application_before)
      end

      ##
      # This gets called after the article index request, providing the articles from the index, and the request
      def after_index_article_request(articles, request)
        run_event(:after_index_article_request, articles, request)
      end

      ##
      # This gets called after the article show request, providing the article being shown, and the request
      def after_show_article_request(article, request)
        run_event(:after_show_article_request, article, request)
      end

      ##
      # This gets called after a request to create an article, providing the article that was created, and the request
      def after_create_article_request(article, request)
        run_event(:after_create_article_request, article, request)
      end

      ##
      # This gets called after a request to update an article, providing the article that was updated, and the request
      def after_update_article_request(article, request)
        run_event(:after_update_article_request, article, request)
      end

      ##
      # This gets called after a request to publish an article (a create or update where the article is marked as published), providing the article that was published, and the request
      def after_publish_article_request(article, request)
        run_event(:after_publish_article_request, article, request)
      end
    end
  end
end