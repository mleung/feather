require File.join(File.dirname(__FILE__), "base")

module Feather
  module Admin
    class Plugins < Base
      before :find_plugin, :only => %w(update delete show)

      def index
        @plugins = Feather::Plugin.all
        display @plugins
      end

      def show(id)
        display @plugin
      end

      def new
        @plugin = Feather::Plugin.new
        display @plugin
      end

      def create(plugin)
        if (@plugin = Feather::Plugin.install(plugin[:url]))
          # Expire cached pages
          Feather::Article.expire_article_index_page
          Feather::Article.expire_article_pages
          # Redirect to the plugin view
          redirect url(:admin_plugin, @plugin.name)
        else
          render :new
        end
      end

      def update(id)
        # Set the plugin to be active (this writes to plugin settings)
        @plugin.active = params[:active] == "true" unless params[:active].blank?
        # Expire cached pages
        Feather::Article.expire_article_index_page
        Feather::Article.expire_article_pages
        # Respond with JS
        render_js
      end

      def delete(id)
        @plugin.destroy
        redirect url(:admin_plugins)
      end

      private
        def find_plugin
          @plugin = Feather::Plugin.get(params[:id])
        end
    end
  end
end