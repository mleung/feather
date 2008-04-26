# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "sessions", :action => "create", :namespace => "admin").name(:login)
        r.match("/logout").to(:controller => "sessions", :action => "destroy", :namespace => "admin").name(:logout)
        r.namespace :admin do |admin|
          admin.resources :users
          admin.resources :sessions
        end
      end
    end
  end
end