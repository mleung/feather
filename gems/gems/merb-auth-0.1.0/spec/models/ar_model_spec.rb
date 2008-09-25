require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require 'active_record'

describe "MA ActiveRecord User Model" do
  
  before(:all) do
    
    Merb.stub!(:orm_generator_scope).and_return("activerecord")
    
    adapter_path = File.join( File.dirname(__FILE__), "..", "..", "lib", "merb-auth", "adapters")
    MA.register_adapter :datamapper, "#{adapter_path}/datamapper"
    MA.register_adapter :activerecord, "#{adapter_path}/activerecord"    
    MA.loaded
    
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(  
      :adapter  => 'sqlite3',   
      :database => ':memory:')
      
    class UserMigration < ActiveRecord::Migration
      def self.up
        create_table "users", :force => true do |t|
          t.column :login,                      :string
          t.column :email,                      :string
          t.column :crypted_password,           :string, :limit => 40
          t.column :salt,                       :string, :limit => 40
          t.column :created_at,                 :datetime
          t.column :updated_at,                 :datetime
          t.column :remember_token,             :string
          t.column :remember_token_expires_at,  :datetime
          t.column :activation_code,            :string, :limit => 40
          t.column :activated_at,               :datetime
          t.column :password_reset_key,         :string
        end
      end
    end
    
    UserMigration.up
    
    class User < ActiveRecord::Base
      include MerbAuth::Adapter::ActiveRecord
      include MerbAuth::Adapter::ActiveRecord::DefaultModelSetup
    end
    
    MA.activate
  end
  
  it_should_behave_like "A MerbAuth User Model"

end