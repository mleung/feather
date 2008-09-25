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
Merb::Router.prepare do 
  slice(:MerbAuth, :name_prefix => nil, :path => 'admin', :default_routes => false )
  # This deferred route allows permalinks to be handled, without a separate rack handler
  match(/.*/).defer_to do |request, params|
    unless (article = Article.find_by_permalink(request.uri.to_s.chomp("/"))).nil?
      {:controller => "articles", :action => "show", :id => article.id}
    end
  end

  # Admin namespace
  namespace :admin do
    resources :configurations
    resources :categories
    resources :plugins
    resources :articles
    match("/dashboard").to(:controller => "dashboard").name(:dashboard)
    match("").to(:controller => "dashboard").name(:dashboard)
  end

  # Year/month/day routes
  match("/:year").to(:controller => "articles", :action => "index").name(:year)
  match("/:year/:month").to(:controller => "articles", :action => "index").name(:month)
  match("/:year/:month/:day").to(:controller => "articles", :action => "index").name(:day)
  
  # Default routes, and index
  default_routes  
  match("/").to(:controller => 'articles', :action =>'index')
end

