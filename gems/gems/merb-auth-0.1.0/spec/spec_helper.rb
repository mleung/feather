require 'rubygems'
require 'merb-core'
require 'spec'
require 'merb-slices'
require 'merb-mailer'


# class Merb::BootLoader::SlicesForSpecs < Merb::BootLoader
#   
#   before Merb::BootLoader::BeforeAppLoads
#   
#   def self.run
#     Merb::Config.use do |c|
#       c[:session_store] = "memory"
#     end
#     Merb::Slices.register_and_load(File.join(File.dirname(__FILE__), '..', 'lib', 'merb-auth.rb'))
#   end
#   
# end

Merb::Plugins.config[:merb_slices][:auto_register] = true
Merb::Plugins.config[:merb_slices][:search_path]   = File.join(File.dirname(__FILE__), '..', 'lib', 'merb-auth.rb')

module Merb
  def self.orm_generator_scope
    :datamapper
  end
end

# Using Merb.root below makes sure that the correct root is set for
# - testing standalone, without being installed as a gem and no host application
# - testing from within the host application; its root will be used
Merb.start_environment(
  :testing => true, 
  :adapter => 'runner', 
  :environment => ENV['MERB_ENV'] || 'test',
  :merb_root => Merb.root,
  :session_store => 'memory'
)


class Merb::Mailer
  self.delivery_method = :test_send
end

path = File.dirname(__FILE__)
# Load up all the shared specs
Dir[path / "shared_specs" / "**" / "*_spec.rb"].each do |f|
  require f
end

# Load up all the spec helpers
Dir[path / "spec_helpers" / "**" / "*.rb"].each do |f|
  require f
end

module Merb
  module Test
    module SliceHelper
      
      # The absolute path to the current slice
      def current_slice_root
        @current_slice_root ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
      end
      
      # Whether the specs are being run from a host application or standalone
      def standalone?
        not $SLICED_APP
      end
      
    end
  end
end

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Merb::Test::SliceHelper)
  config.include(ValidModelHashes)
  config.before(:each) do
    Merb::Router.prepare { |r| r.add_slice(:MerbAuth) } if standalone?
  end
end


# GLobal helpers for merb-auth
def reload_ma!(create_class = nil)
  Object.class_eval do
    remove_const("User") if defined?(User)
    remove_const("MA") if defined?(MA)
    remove_const("MerbAuth")
  end
  load File.join(File.dirname(__FILE__), "..", "lib", "merb-auth.rb")
  register_datamapper!
  stub_orm_scope

  MA.load_slice
  yield if block_given?
  MA[:user] = nil
  ::DataMapper::Resource.descendants.delete(User) if defined?(User)
  MA.loaded
  unless create_class.nil?
    Object.class_eval <<-EOS
      class #{create_class}
        include DataMapper::Resource
        include MerbAuth::Adapter::DataMapper
        include MerbAuth::Adapter::DataMapper::DefaultModelSetup
      end
      EOS
  end 
  Merb::BootLoader::MaLoadPlugins.run
  MA.activate
end
