# This is designed to pick up requests to any configured permalink, allowing existing links to be retained
# and new permalinks to be intercepted and processed
# Probably a bit too complicated for a route, hence a dedicated handler
permalink = Proc.new do |env|
  request = Merb::Request.new(env)
  controller = Articles.new(request, 200)
  if Merb::Dispatcher.use_mutex
    Merb::Dispatcher.class_eval("@@mutex").synchronize { controller._dispatch(:show) }
  else
    controller._dispatch(:show)
  end
  [controller.status, controller.headers, controller.body]
end

# This is designed to handle routes for plugins
plugins = Proc.new do |env|
  request = Merb::Request.new(env)
  # See if the route matches a plugin route
  route = Hooks::Routing.routes.select { |route| route[:url] == request.uri.to_s }.first
  if route.nil?
    # If not, 404 so it can carry on to be processed by the rest of the app
    [404, [], nil]
  else
    # If it can be found, ensure the controller is valid
    raise "Unable to find #{route[:controller]}!" if !Merb::Controller._subclasses.include?(route[:controller])
    # Instantiate the controller
    controller = Object.full_const_get(route[:controller]).new(request, 200)
    # Dispatch the request
    if Merb::Dispatcher.use_mutex
      Merb::Dispatcher.class_eval("@@mutex").synchronize { controller._dispatch(route[:action]) }
    else
      controller._dispatch(route[:action])
    end
    # Return the result
    [controller.status, controller.headers, controller.body]
  end
end

# Create the Merb application
merb = Merb::Rack::Application.new

# Tell Rack to run the permalink handler first, and if no article can be found for the request, on to the plugin handler, then finally pass it to Merb
run Rack::Cascade.new([permalink, plugins, merb])