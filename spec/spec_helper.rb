$TESTING=true
require 'rubygems'
require 'merb-core'

Merb.start_environment :environment => (ENV['MERB_ENV'] || 'test'), :merb_root => File.join(File.dirname(__FILE__), ".." )

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end