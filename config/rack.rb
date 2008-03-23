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

# Create the Merb application
merb = Merb::Rack::Application.new

# Tell Rack to run the permalink handler first, and if no article can be found for the request, pass it to Merb
run Rack::Cascade.new([permalink, merb])