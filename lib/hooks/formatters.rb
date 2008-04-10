module Hooks
  module Formatters
    class << self
      ##
      # This registers a block to format article content
      def register_formatter(name, &block)
        @formatters = {"default" => default_formatter} if @formatters.nil?
        raise "Formatter `#{name}` already registered!" unless @formatters[name].nil?
        @formatters[name] = block
      end
      
      ##
      # This returns an array of available formatters that have been registered
      def available_formatters
        @formatters = {"default" => default_formatter} if @formatters.nil?
        @formatters.keys.select { |key| key == "default" || Hooks::is_hook_valid?(@formatters[key]) }
      end
      
      ##
      # This returns a default formatter used for replacing line breaks within text
      # This is the only formatter included within feather-core
      def default_formatter
        Proc.new do |text|
          text.gsub("\r\n", "\n").gsub("\n", "<br />")
        end
      end
      
      ##
      # This performs the relevant formatting for the article, and returns the formatted article content
      def format_article(article)
        format_text(article.formatter, article.content)
      end
      
      ##
      # This performs the requested formatting, returning the formatted text
      def format_text(formatter, text)
        formatter = "default" unless available_formatters.include?(formatter)
        @formatters[formatter].call(text)
      end
    end
  end
end