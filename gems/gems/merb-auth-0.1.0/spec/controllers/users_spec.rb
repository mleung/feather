require File.dirname(__FILE__) + '/../spec_helper'

describe MA::Users do
  
  before(:all) do
    
    
    MA[:use_activation] = true
    
    DataMapper.setup(:default, 'sqlite3::memory:')
    Merb.stub!(:orm_generator_scope).and_return("datamapper")
    
    adapter_path = File.join( File.dirname(__FILE__), "..", "..", "lib", "merb-auth", "adapters")
    MA.register_adapter :datamapper, "#{adapter_path}/datamapper"
    MA.register_adapter :activerecord, "#{adapter_path}/activerecord"    
    MA.load_slice
    MA.activate

    class User
      include MA::Adapter::DataMapper
      include MerbAuth::Adapter::DataMapper::DefaultModelSetup
    end
  end
  
  before(:each) do
    User.clear_database_table
  end
  
  it "should have MixinSessionContainer mixed into the User Controller" do
    Merb::Controller.should include(::Merb::SessionMixin)    
  end
  
  it "should provide a current_ma_user method" do
    MA::Users.new({}).should respond_to(:current_ma_user)
    MA::Users.new({}).should respond_to(:current_user)
  end
  
  it "should provide a current_user method" do
    MA::Users.new({}).should respond_to(:current_ma_user=)
    MA::Users.new({}).should respond_to(:current_user=)
  end
  
  it 'allows signup' do
     # lambda do
     users = User.count
       controller = create_user
       controller.should redirect      
     User.count.should == (users + 1)
     # end.should change(User, :count).by(1)
   end
    
   it 'requires password on signup' do
     lambda do
       controller = create_user(:password => nil)
       controller.assigns(:user).errors.on(:password).should_not be_nil
       controller.should respond_successfully
     end.should_not change(User, :count)
   end
     
   it 'requires password confirmation on signup' do
     lambda do
       controller = create_user(:password_confirmation => nil)
       controller.assigns(:user).errors.should_not be_empty
       controller.should respond_successfully
     end.should_not change(User, :count)
   end
   
   it 'requires email on signup' do
     lambda do
       controller = create_user(:email => nil)
       controller.assigns(:user).errors.on(:email).should_not be_nil
       controller.should respond_successfully
     end.should_not change(User, :count)
   end
   
   it "should have a route for user activation" do
     request_to("/merb-auth/users/activate/1234") do |params|
       params[:controller].should == "Users"
       params[:action].should == "activate" 
       params[:activation_code].should == "1234"    
     end
   end

   it 'activates user' do
     controller = create_user(:email => "aaron@example.com", :password => "test", :password_confirmation => "test")
     @user = controller.assigns(:user)
     User.authenticate('aaron@example.com', 'test').should be_nil
     controller = get "/merb-auth/users/activate/#{@user.activation_code}" 
     controller.should redirect_to("/")
     User.authenticate('aaron@example.com', 'test').should_not be_nil
   end

  it "should log the user in automatically on creation if :use_activation is false" do
    MA[:use_activation] = false
    dispatch_to(MA::Users, :create, :user => {:email => "aaron@example.com", :password => "test", :password_confirmation => "test"}) do |c|
      u = mock("user")
      User.should_receive(:new).and_return(u)
      u.should_receive(:save).and_return(true)
      c.should_receive(:current_ma_user=).with(u)
    end
  end

  it "should not log the user in automatically on creation if :use_activation is true" do
    MA[:use_activation] = true
    dispatch_to(MA::Users, :create, :user => {:email => "aaron@example.com", :password => "test", :password_confirmation => "test"}) do |c|
      u = mock("user")
      User.should_receive(:new).and_return(u)
      u.should_receive(:save).and_return(true)
      c.should_not_receive(:current_ma_user=)
    end
  end

   
   
     
   def create_user(options = {})
     post "/merb-auth/users/", :user => valid_user_hash.merge(options)
   end
end
