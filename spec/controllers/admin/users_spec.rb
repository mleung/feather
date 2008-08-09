require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')
require File.join(File.dirname(__FILE__), "../..", 'user_spec_helper.rb')

include UserHelper

describe MA::Users do
  before(:all) do
    
    MA[:use_activation] = false
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
     
     def create_user(options = {})
       post "/admin/users/", :user => valid_user_hash.merge(options)
     end

end
