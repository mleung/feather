require File.dirname(__FILE__) + '/spec_helper'
require 'activerecord'
require 'dm-core'

# For note purposes
# Merb::Slices.register_and_load(../../lib/merb-auth.rb)

describe MerbAuth do
  
  before(:all) do
    @adapter_path = File.dirname(__FILE__) / ".." / "lib" / "merb-auth" / "adapters"
    @ar_path = @adapter_path / "activerecord"
    @config = Merb::Slices::config[:merb_auth]
    DataMapper.setup(:default, 'sqlite3::memory:')
  end
  
  before(:each) do
    register_activerecord!
    register_datamapper!
  end
  
  after(:each) do
    MA.clear_adapter_list!
    MA[:user] = nil
    ::DataMapper::Resource.descendants.delete(User) if defined?(User)
    Object.class_eval do
      remove_const("User") if defined?(User)
    end
    MA::Adapter.module_eval do
      remove_const("DataMapper") if defined?(MA::Adapter::DataMapper)
    end if defined?(MA::Adapter)
  end
  
  def stub_orm_scope(scope = "datamapper")
    Merb.stub!(:orm_generator_scope).and_return(scope)
  end
  
  def register_activerecord!
    MA.register_adapter :activerecord, "#{@adapter_path}/activerecord"
  end
  
  def register_datamapper!
    MA.register_adapter :datamapper, "#{@adapter_path}/datamapper"
  end
  
  describe "Adapter Loading" do
  
    it "should allow adapters to register themselves" do
      MA.adapters[:activerecord][:path].should == @ar_path
    end
  
    it "should clear the registered adapters (for specs only)" do
      MA.adapters.should_not be_empty
      MA.clear_adapter_list!
      MA.adapters.should be_empty
    end
  
    it "should return a hash of registered adapters" do
      MA.adapters.should be_a_kind_of(Hash)
      MA.adapters.keys.should include(:activerecord)
      MA.adapters.keys.should include(:datamapper)
    end
  
    it "should load the adapter" do
      defined?(MA::Adapter::DataMapper).should be_nil
      MA.load_adapter!(:datamapper)
      defined?(MA::Adapter::DataMapper).should_not be_nil
    end
    
    it "should raise an error if an adapter is loaded that has not been registered" do
      lambda do
        MA.load_adapter!(:no_adapter)
      end.should raise_error(RuntimeError, "MerbAuth: Adapter Not Registered - no_adapter")
    end
    
    it "should load the adapter scope as the type if there is no specified adapter type" do
      Merb.should_receive(:orm_generator_scope).and_return("datamapper")
      MA.load_adapter!
    end

    it "should load the correct adapter in the loaded hook" do
      stub_orm_scope
      defined?(MA::Adapter::DataMapper).should be_nil
      MA.loaded
      defined?(MA::Adapter::DataMapper).should_not be_nil    
    end
  
    it "should expose the adapter model class via the configuration" do
      stub_orm_scope
      MA.load_adapter!
      class User
        include MA::Adapter::DataMapper
      end
      MA[:user].should == User
    end
    
    it "should allow DM to create it's table correctly" do
      stub_orm_scope 
      MA[:user] = nil
      MA.load_adapter!
      class User
        include MA::Adapter::DataMapper
        include MA::Adapter::DataMapper::DefaultModelSetup
      end
      
      results = DataMapper.auto_migrate!
      results.should include(User)
    end
    
  end

  describe "controller Plugin loading" do
        
    def add_test_plugin!
      MA.plugins["Tester"] = File.join(File.dirname(__FILE__), "controllers", "plugins", "test_plugin.rb")
    end
    
    before(:each) do
      reload_ma!
    end
        
    after(:all) do
      reload_ma!
    end
    
    it "should allow for registration" do
      defined?(MA::Controller::Tester).should be_nil
      reload_ma!("User"){  add_test_plugin! }
      defined?(MA::Controller::Tester).should_not be_nil
      MA::Users.should include(MA::Controller::Tester)
    end
    
    it "should overwrite the new method" do
      Object.class_eval <<-EOS
        class User
          include MerbAuth::Adapter::DataMapper
          include MerbAuth::Adapter::DataMapper::DefaultModelSetup
        end
        EOS
      controller = dispatch_to(MA::Users, :new)
      controller.body.should_not == "NEW TEST"
      reload_ma!("User"){ add_test_plugin!}
      controller = dispatch_to(MA::Users, :new)
      controller.body.should == "NEW TEST"      
    end
  end

end

describe "MerbAuth (module)" do
  
  # Feel free to remove the specs below
  
  it "should be registered in Merb::Slices.slices" do
    Merb::Slices.slices.should include(MerbAuth)
  end
  
  it "should have an :identifier property" do
    MerbAuth.identifier.should == "merb-auth"
  end
  
  it "should have an :identifier_sym property" do
    MerbAuth.identifier_sym.should == :merb_auth
  end
  
  it "should have a :root property" do
    MerbAuth.root.should == current_slice_root
    MerbAuth.root_path('app').should == current_slice_root / 'app'
  end
  
  it "should have metadata properties" do
    MerbAuth.description.should == "MerbAuth is a Merb slice that provides authentication"
    MerbAuth.version.should == "0.1.0"
    MerbAuth.author.should == "Merb Core"
  end
  
  it "should have a config property (Hash)" do
    MerbAuth.config.should be_kind_of(Hash)
  end
  
  it "should have a :layout config option set" do
    MerbAuth.config[:layout].should == :merb_auth
  end
  
  it "should have a dir_for method" do
    app_path = MerbAuth.dir_for(:application)
    app_path.should == current_slice_root / 'app'
    [:view, :model, :controller, :helper, :mailer, :part].each do |type|
      MerbAuth.dir_for(type).should == app_path / "#{type}s"
    end
    public_path = MerbAuth.dir_for(:public)
    public_path.should == current_slice_root / 'public'
    [:stylesheet, :javascript, :image].each do |type|
      MerbAuth.dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a app_dir_for method" do
    root_path = MerbAuth.app_dir_for(:root)
    root_path.should == Merb.root / 'slices' / 'merb-auth'
    app_path = MerbAuth.app_dir_for(:application)
    app_path.should == root_path / 'app'
    [:view, :model, :controller, :helper, :mailer, :part].each do |type|
      MerbAuth.app_dir_for(type).should == app_path / "#{type}s"
    end
    public_path = MerbAuth.app_dir_for(:public)
    public_path.should == Merb.dir_for(:public) / 'slices' / 'merb-auth'
    [:stylesheet, :javascript, :image].each do |type|
      MerbAuth.app_dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a public_dir_for method" do
    public_path = MerbAuth.public_dir_for(:public)
    public_path.should == '/slices' / 'merb-auth'
    [:stylesheet, :javascript, :image].each do |type|
      MerbAuth.public_dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should keep a list of path component types to use when copying files" do
    (MerbAuth.mirrored_components & MerbAuth.slice_paths.keys).length.should == MerbAuth.mirrored_components.length
  end
  
end