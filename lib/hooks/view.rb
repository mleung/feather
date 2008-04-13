module Hooks
  module View
    class << self
      ##
      # This registers a partial view, effectively adding a call to the specified partial for the specified view hook point
      def register_partial_view(name, partial)
        register_view(location_of_caller[0], name, {:partial => partial})
      end
      
      ##
      # This registers a dynamic view, effectively adding string content to the specified view hook point, with a specified identifier
      def register_dynamic_view(name, content, id = nil)
        id.nil? ? register_view(location_of_caller[0], name, {:content => content}) : register_view(location_of_caller[0], name, {:content => content}, id)
      end

      ##
      # This registers a view with the specified id, for the specified view name, and with optional options
      def register_view(caller, name, options, id = rand(1000000).to_s)
        raise "Unable to register view for unrecognized plugin! (#{caller})" if (plugin = Hooks::get_plugin_by_caller(caller)).nil?
        @view_hooks ||= {}
        @view_hooks[plugin.id] ||= []
        @view_hooks[plugin.id] << {:id => id, :name => name}.merge(options)
      end
      
      ##
      # This removes any view hooks registered with the specified identifier
      def deregister_dynamic_view(id)
        @view_hooks.keys.each do |key|
          @view_hooks[key].each do |view|
            @view_hooks[key].delete(view) if view[:id] == id
          end
        end
      end

      ##
      # This iterates through all registered views, building an array to be rendered
      def plugin_views
        plugin_views = []
        unless @view_hooks.nil? || @view_hooks.values.nil?
          Plugin.all(:active => true).each do |plugin|
            @view_hooks[plugin.id].each { |view| plugin_views << view.merge({:plugin => plugin}) } unless @view_hooks[plugin.id].nil? || @view_hooks[plugin.id].empty?
          end
        end
        plugin_views.sort { |a, b| a[:plugin].name <=> b[:plugin].name }
      end
      
      ##
      # This removes any view hooks for the specified plugin
      def remove_plugin_hooks(id)
        @view_hooks.delete(id)
      end
    end
  end
end