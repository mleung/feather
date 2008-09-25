dir = File.dirname(__FILE__)

require 'rubygems'
require 'spec'
require 'merb-core'
require 'merb-slices'

Merb::BootLoader.before_app_loads do
  Merb::Slices::config[:merb_auth][:forgotten_password] = true
end

require File.join(File.expand_path(dir), "..", "..", "..", "spec", "spec_helper.rb")

  
module Merb
  def self.orm_generator_scope
    "datamapper"
  end
end
  

DataMapper.setup(:default, 'sqlite3::memory:')
adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "merb-auth", "adapters"))
MA.register_adapter :datamapper, "#{adapter_path}/datamapper"
MA.register_adapter :activerecord, "#{adapter_path}/activerecord"    
MA.load_slice

class User
  include MA::Adapter::DataMapper
end

User.auto_migrate!
MA.activate
Merb::Router.prepare{|r| r.add_slice(:MerbAuth)}
MA.load_plugins!

