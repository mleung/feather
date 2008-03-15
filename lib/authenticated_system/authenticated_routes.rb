# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "Sessions", :action => "create", :namespace => "admin").name(:login)
        r.match("/logout").to(:controller => "Sessions", :action => "destroy", :namespace => "admin").name(:logout)
        r.resources :users
      end
    end
  end
end