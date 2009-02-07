if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)
  $:.unshift File.join(File.dirname(__FILE__), "..", "app", "models")
  $:.unshift File.join(File.dirname(__FILE__), "..", "app", "controllers")
  $:.unshift File.join(File.dirname(__FILE__), "..", "app", "helpers")

  dependency 'merb-slices'
  Merb::Plugins.add_rakefiles "feather/merbtasks", "feather/slicetasks", "feather/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :feather-slice
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:feather][:layout] ||= :application
  
  require 'config/dependencies.rb'
  
  # All Slice code is expected to be namespaced inside a module
  module Feather
    
    # Slice metadata
    self.description = "The slice version of Feather, the extensible, lightweight blogging engine for Merb"
    self.version = "0.5"
    self.author = "El Draper"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
      Merb::Authentication.user_class = Feather::User
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(Feather)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :feather_slice_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      require File.join(File.dirname(__FILE__), "feather", "padding")
      require File.join(File.dirname(__FILE__), "feather", "hooks")
      require File.join(File.dirname(__FILE__), "feather", "database")
      require File.join(File.dirname(__FILE__), "feather", "plugin_dependencies")

      # This loads the plugins
      begin
       Feather::Plugin.all.each do |p|
         begin
           p.load
           Merb.logger.info("\"#{p.name}\" loaded")
         rescue Exception => e
           Merb.logger.info("\"#{p.name}\" failed to load : #{e.message}")
         end
       end
      rescue Exception => e
       Merb.logger.info("Error loading plugins: #{e.message}")
      end
       
      # Load all plugin routes
      Feather::Hooks::Routing.load_routes(scope)
      
      # This deferred route allows permalinks to be handled, without a separate rack handler
      scope.match("/:controller", :controller => '.*').defer_to do |request, params|
        unless (id = Feather::Article.routing[request.uri.to_s.chomp("/")]).nil?
          params.merge!({:controller => "feather/articles", :action => "show", :id => id})
        end
      end

      # Admin namespace
      scope.namespace "admin", :path => "admin", :name_prefix => "admin" do
        scope.resource :configuration, :path => "admin/configuration", :name_prefix => "admin", :controller => "admin/configurations"
        scope.resources :plugins, :path => "admin/plugins", :name_prefix => "admin", :controller => "admin/plugins"
        scope.resources :articles, :path => "admin/articles", :name_prefix => "admin", :controller => "admin/articles"
        scope.resources :users, :path => "admin/users", :name_prefix => "admin", :controller => "admin/users"
        scope.resource :dashboard, :path => "admin/dashboard", :name_prefix => "admin", :controller => "admin/dashboards"
      end
      scope.match("/admin").to(:action => "show", :controller => "admin/dashboards")

      # Year/month/day routes
      scope.match("/:year").to(:controller => "articles", :action => "index").name(:year)
      scope.match("/:year/:month").to(:controller => "articles", :action => "index").name(:month)
      scope.match("/:year/:month/:day").to(:controller => "articles", :action => "index").name(:day)

      # Default routes, and index 
      scope.match("/").to(:controller => 'articles', :action =>'index')
    end
  end
  
  # Setup the slice layout for Feather
  #
  # Use Feather.push_path and Feather.push_app_path
  # to set paths to feather-level and app-level paths. Example:
  #
  # Feather.push_path(:application, Feather.root)
  # Feather.push_app_path(:application, Merb.root / 'slices' / 'feather-slice')
  # ...
  #
  # Any component path that hasn't been set will default to Feather.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  Feather.setup_default_structure!
  
  # Add dependencies for other Feather classes below. Example:
  # dependency "feather/other"
  
end