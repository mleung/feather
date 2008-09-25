if defined?(Merb::Plugins)

  require "digest/sha1"
  require "merb-mailer"
  require "merb_helpers"
  
  load File.join(File.dirname(__FILE__), "merb-auth", "initializer.rb")
  
  Dir[File.dirname(__FILE__) / "merb-auth" / "controller" / "**" / "*.rb"].each do |f|
    load f
  end
  
  adapter_path = File.join( File.dirname(__FILE__), "merb-auth", "adapters")
  load File.join(adapter_path,  "common.rb")
  
  MA = MerbAuth
  MA.register_adapter :datamapper, "#{adapter_path}/datamapper"
  MA.register_adapter :activerecord, "#{adapter_path}/activerecord"
  
  Merb::Plugins.add_rakefiles "merb-auth/merbtasks", "merb-auth/slicetasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  
  class Merb::BootLoader::MaLoadPlugins < Merb::BootLoader
    after Merb::BootLoader::LoadClasses
    
    def self.run
      MA.load_plugins!
    end    
  end
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :merb_auth
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:merb_auth] ||= {}
  Merb::Slices::config[:merb_auth][:layout] ||= :merb_auth
  
  # All Slice code is expected to be namespaced inside a module
  module MerbAuth


    def self.plugins
      @@plugins ||= {}
    end
    
    def self.add_routes(&blk)
      custom_routes << blk
    end
    
    def self.custom_routes
      @custom_routes ||= []
    end
    
    def self.setup_custom_routes!
      Merb.logger.info "Adding custom routes"
      custom_routes.each do |r|
        r.call(MA[:router_scope])
      end
    end
    
    # Slice metadata
    self.description = "MerbAuth is a Merb slice that provides authentication"
    self.version = "0.1.0"
    self.author = "Merb Core"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally
    def self.loaded
      # Setup the login field to use
      MA[:login_field] = (MA[:login_field] || :email).to_sym
      
      MA.load_adapter!
      
      Merb::Controller.send(:include, MA::Controller::Helpers)
      # sends the methoods to the controllers as an include so that other mixins can
      # overwrite them
      MA::Users.send(     :include, MA::Controller::UsersBase)
      MA::Sessions.send(  :include, MA::Controller::SessionsBase)
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init  
      
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
      # Make the aliases for current stuff
       Merb::Controller.module_eval do
        alias_method :"current_#{MA[:single_resource]}", :current_ma_user
        alias_method :"current_#{MA[:single_resource]}=", :current_ma_user=
      end
    end
    
    # Deactivation hook - triggered by Merb::Slices#deactivate
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    def self.setup_router(scope)
      MA[:router_scope] = scope # Hangs onto the scope for the plugins which are loaded after the routes are setup
      
      MA.setup_custom_routes!
      
      plural_model_path = MA[:route_path_model] || MA[:plural_resource] 
      plural_model_path ||= "User".snake_case.singularize.pluralize
      plural_model_path = plural_model_path.to_s.match(%r{^/?(.*?)/?$})[1]
      single_model_name = plural_model_path.singularize
      
      plural_session_path = MA[:route_path_session] || "sessions"
      plural_session_path = plural_session_path.to_s.match(%r{^/?(.*?)/?$})[1]
      single_session_name = plural_session_path.singularize
      
      activation_name = (MA[:single_resource].to_s << "_activation").to_sym
      
      MA[:routes] = {:user => {}}
      MA[:routes][:user][:new]       ||= :"new_#{single_model_name}"
      MA[:routes][:user][:show]      ||= :"#{single_model_name}"
      MA[:routes][:user][:edit]      ||= :"edit_#{single_model_name}"
      MA[:routes][:user][:delete]    ||= :"delete_#{single_model_name}"
      MA[:routes][:user][:index]     ||= :"#{plural_model_path}"
      MA[:routes][:user][:activate]  ||= :"#{single_model_name}_activation"
          
      # Setup the model path
      scope.to(:controller => "Users") do |c|
        c.match("/#{plural_model_path}") do |u|
          # setup the named routes          
          u.match("/new",             :method => :get ).to( :action => "new"     ).name(MA[:routes][:user][:new])
          u.match("/:id",             :method => :get ).to( :action => "show"    ).name(MA[:routes][:user][:show])
          u.match("/:id/edit",        :method => :get ).to( :action => "edit"    ).name(MA[:routes][:user][:edit])
          u.match("/:id/delete",      :method => :get ).to( :action => "delete"  ).name(MA[:routes][:user][:delete])
          u.match("/",                :method => :get ).to( :action => "index"   ).name(MA[:routes][:user][:index])
          u.match("/activate/:activation_code", :method => :get).to( :action => "activate").name(MA[:routes][:user][:activate])
          
          # Make the anonymous routes
          u.match(%r{(/|/index)?(\.:format)?$},  :method => :get    ).to( :action => "index")
          u.match(%r{/new$},                     :method => :get    ).to( :action => "new")
          u.match(%r{/:id(\.:format)?$},         :method => :get    ).to( :action => "show")
          u.match(%r{/:id/edit$},                :method => :get    ).to( :action => "edit")
          u.match(%r{/:id/delete$},              :method => :get    ).to( :action => "delete")
          u.match(%r{/?(\.:format)?$},           :method => :post   ).to( :action => "create")      
          u.match(%r{/:id(\.:format)?$},         :method => :put    ).to( :action => "update")
          u.match(%r{/:id(\.:format)?$},         :method => :delete ).to( :action => "destroy")
        end
      end
      
      scope.match("/signup").to(:controller => "Users",    :action => "new"    ).name(:signup)
      scope.match("/login" ).to(:controller => "sessions", :action => "create" ).name(:login)
      scope.match("/logout").to(:controller => "sessions", :action => "destroy").name(:logout)
    end
    
  end
  
  # Setup the slice layout for MerbAuth
  #
  # Use MerbAuth.push_path and MerbAuth.push_app_path
  # to set paths to merb_auth-level and app-level paths. Example:
  #
  # MerbAuth.push_path(:application, MerbAuth.root)
  # MerbAuth.push_app_path(:application, Merb.root / "slices" / "merb-auth")
  # ...
  #
  # Any component path that hasn't been set will default to MerbAuth.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  MerbAuth.setup_default_structure!

end

Dir[File.join(File.dirname(__FILE__), "..", "plugins/*/init.rb")].each do |f|
  require f
end