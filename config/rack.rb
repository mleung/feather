# Create the Merb application
merb = Merb::Rack::Application.new

# Tell Rack to run the Merb application
run Rack::Cascade.new([merb])