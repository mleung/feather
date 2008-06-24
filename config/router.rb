# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # This deferred route allows permalinks to be handled, without a separate rack handler
  r.defer_to do |request, path_match|
    unless (article = Article.find_by_permalink(request.uri.to_s.chomp("/"))).nil?
      {:controller => "articles", :action => "show", :id => article.id}
    end
  end
  
  # Admin namespace
  r.namespace :admin do |admin|
    admin.resource :configurations
    admin.resources :dashboard
    admin.resources :categories
    admin.resources :plugins
    admin.resources :articles
    admin.match("").to(:controller => "dashboard", :action => "index")
  end
  
  # Year/month/day routes
  r.match("/:year").to(:controller => "articles", :action => "index").name(:year)
  r.match("/:year/:month").to(:controller => "articles", :action => "index").name(:month)
  r.match("/:year/:month/:day").to(:controller => "articles", :action => "index").name(:day)
  
  # Default routes, and index
  r.default_routes  
  r.match('/').to(:controller => 'articles', :action =>'index')
end

AuthenticatedSystem.add_routes
