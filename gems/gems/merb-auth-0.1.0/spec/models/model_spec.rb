require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require 'dm-core'

describe "MA User Model" do
  
  before(:all) do
    DataMapper.setup(:default, 'sqlite3::memory:')
    Merb.stub!(:orm_generator_scope).and_return("datamapper")
    
    adapter_path = File.join( File.dirname(__FILE__), "..", "..", "lib", "merb-auth", "adapters")
    MA.register_adapter :datamapper, "#{adapter_path}/datamapper"
    MA.register_adapter :activerecord, "#{adapter_path}/activerecord"    
    MA.loaded
    
    class User
      include MA::Adapter::DataMapper
      include MA::Adapter::DataMapper::DefaultModelSetup
    end
  end
  
  it_should_behave_like "A MerbAuth User Model"

end