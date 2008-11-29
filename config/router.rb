# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/routerb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |router|
  # Load all plugins
  begin
    Feather::Plugin.all(:order => [:name]).each do |p|
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
  Feather::Hooks::Routing.load_routes(router)
  
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")
  # This deferred route allows permalinks to be handled, without a separate rack handler
  match(/.*/).defer_to do |request, params|
    unless (article = Feather::Article.find_by_permalink(request.uri.to_s.chomp("/"))).nil?
      {:controller => "feather/articles", :action => "show", :id => article.id}
    end
  end
  
  # Admin namespace
  namespace "feather/admin", :path => "admin", :name_prefix => "admin" do
    resource :configuration
    resources :plugins
    resources :articles
    resources :users
    resource :dashboard
  end
  match("/admin").to(:action => "show", :controller => "feather/admin/dashboards")

  # Year/month/day routes
  match("/:year").to(:controller => "feather/articles", :action => "index").name(:year)
  match("/:year/:month").to(:controller => "feather/articles", :action => "index").name(:month)
  match("/:year/:month/:day").to(:controller => "feather/articles", :action => "index").name(:day)
  
  # Default routes, and index
  default_routes  
  match("/").to(:controller => 'feather/articles', :action =>'index')
end

