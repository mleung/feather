require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Passwords controller" do
  
  before(:each) do
    User.clear_database_table
    @user = User.create(valid_user_hash.with(
      :password => "test",
      :password_confirmation => "test",
      :login => "gary",
      :email => "gary@example.com"
    ))
    @user.activate
    @user.reload
    @deliveries = Merb::Mailer.deliveries
  end
  
  after(:each) do
    Merb::Mailer.deliveries.clear
  end
  
  describe "new" do
    
    it "should render a form to create a reset password" do
      c = dispatch_to(MA::Passwords, :new)
      c.body.should have_tag(:form, :action => url(:merb_auth_passwords), :method => "post")
    end
  end
  
  describe "edit" do
    
    def dispatch_edit(opts = {})
      dispatch_to(MA::Passwords, :edit, opts = {}) do |c|
        c.stub!(:current_ma_user).and_return(@user)
      end
    end
    
    it "should require the user to be logged in" do
      c = dispatch_to(MA::Passwords, :edit)
      c.should redirect_to(url(:login))
    end
    
    it "should have a form that is posted to url(:passwords)" do
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:merb_auth_passwords), :method => "post")
    end
    
    it "the form should have password and confirmation password fields" do
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:merb_auth_passwords), :method => "post") do |d|
        d.should have_tag(:input, :type => "hidden", :name => "_method")
        d.should have_tag(:input, :type => "password", :id => "user_password")
        d.should have_tag(:input, :type => "password", :id => "user_password_confirmation")
      end
    end
    
    it "should show the old password confirmation box if the user does not have a forgotten password" do
      @user.clear_forgot_password!
      @user.reload!
      @user.should_not have_forgotten_password
      
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:merb_auth_passwords), :method => "post") do |d|
        d.should have_tag(:input, :type => "hidden", :name => "_method")
        d.should have_tag(:input, :type => "password", :id => "user_password")
        d.should have_tag(:input, :type => "password", :id => "user_password_confirmation")
        d.should have_tag(:input, :type => "password", :name => "current_password")
      end
    end
    
    it "should not show the old password ocnfirmation box if the user does have a forgotten password" do
      @user.forgot_password!
      @user.reload!
      
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:merb_auth_passwords), :method => "post") do |d|
        d.should have_tag(:input, :type => "hidden", :name => "_method")
        d.should have_tag(:input, :type => "password", :id => "user_password")
        d.should have_tag(:input, :type => "password", :id => "user_password_confirmation")
        d.should_not have_tag(:input, :type => "password", :name => "current_password")
      end
    end
  end
  
  describe "create" do
    def dispatch_create(opts = {})
      dispatch_to(MA::Passwords, :create, {:email => @user.email}.merge!(opts) )
    end
    
    it "should set the users password to forgotten" do
      @user.should_not have_forgotten_password
      dispatch_create
      @user.reload!
      @user.should have_forgotten_password
    end
    
    it "should only change the user who's email was sent" do
      user = User.create(valid_user_hash)
      user.should_not be_new_record
      
      @user.should_not have_forgotten_password
      user.should_not have_forgotten_password
      
      dispatch_create(:email => user.email)
      
      user.reload!
      @user.reload!
      
      @user.should_not have_forgotten_password
      user.should have_forgotten_password
    end
    
    it "should redirect" do
      c = dispatch_create
      c.should redirect
    end
    
    it "should raise an unauthorized if the user is logged in, and not the owner of the email" do
      user = User.create(valid_user_hash)
      lambda do
        c = dispatch_to(MA::Passwords, :create, :email => user.email) do |c|
          c.stub!(:current_ma_user).and_return(@user)
        end
      end.should raise_error(Merb::Controller::Unauthorized)
    end
    
    it "should raise a NotFound error if the users email does not exist" do
      lambda do
        c = dispatch_create(:email => "does_not_exist@blah.com")
      end.should raise_error(Merb::Controller::NotFound)
    end
    
    it "should send a notification email that the password is to be resent" do
      c = dispatch_create
      c.should redirect_to("/")
      @user.reload!
      @deliveries.last.should_not be_nil
      @deliveries.last.text.should include(url(:merb_auth_passwords, @user.password_reset_key))
    end
  end
  
  describe "show" do
    
    def dispatch_show(opts = {})
      dispatch_to(MA::Passwords, :show, opts)
    end
    
    it "should redirect to edit if given a valid reset key" do
      @user.forgot_password!
      c = dispatch_show(:id => @user.password_reset_key)
      c.should redirect_to(url(:merb_auth_edit_password_form))
    end
    
    it "should redirect to home if given an invalid reset key" do
      c = dispatch_show(:id => "11234")
      c.should redirect_to("/")
    end
    
    it "should log the user in" do
      @user.forgot_password!
      c = dispatch_show(:id => @user.password_reset_key)
      @user.reload!
      c.should be_logged_in
      c.send(:current_ma_user).should == @user
    end
  end
  
  describe "update" do
    
    def dispatch_update(opts = {})
      dispatch_to(MA::Passwords, :update, opts){|c| c.stub!(:current_ma_user).and_return(@user)}
    end
    
    it "should require the user to be logged in" do
      c = dispatch_to(MA::Passwords, :update)
      c.should redirect_to(url(:login))
    end
    
    it "should update the current_users password with pw and pw conf if there is a password_reset_key present" do
      @user.forgot_password!
      @user.password_reset_key.should_not be_nil
      c = dispatch_update(:user => {:password => "gahh", :password_confirmation => "gahh"})
      @user.reload! 
      User.authenticate(@user.email, "gahh").should == @user      
    end
    
    it "should change the password when given a current password if there is no password_reset_key present" do
      @user.should_not have_forgotten_password
      c = dispatch_update(:user => {:password => "gahh", :password_confirmation => "gahh"}, :current_password => "test")
      @user.reload!
      User.authenticate(@user.email, "gahh").should == @user
    end
    
    it "should not change the password when not given a current password if there is no password_reset_key present" do
      @user.should_not have_forgotten_password
      c = dispatch_update(:user => {:password => "gahh", :password_confirmation => "gahh"})
      @user.reload!
      User.authenticate(@user.email, "gahh").should be_nil
      User.authenticate(@user.email, "test").should == @user
    end
    
    it "should not change the password when the current password is wrong" do
      @user.should_not have_forgotten_password
      c = dispatch_update(:user => {:password => "gahh", :password_confirmation => "gahh"}, :current_password => "wrong")
      @user.reload!
      User.authenticate(@user.email, "wrong").should be_nil
      User.authenticate(@user.email, "test").should == @user
    end
    
    it "should clear the password_reset_key" do
      @user.forgot_password!
      @user.should have_forgotten_password
      dispatch_update(:user => {:password => "gahh", :password_confirmation => "gahh"})
      @user.reload!
      @user.should_not have_forgotten_password
    end
    
    it "should redirect to edit back to edit if the passwords do not match and not delete the forgotten password" do
      @user.forgot_password!
      c = dispatch_update(:user => {:password => "blah", :password_confirmation => "foo"})
      @user.reload!
      User.authenticate(@user.email, "blah").should be_nil
      c.should redirect_to(url(:merb_auth_edit_password_form))
      @user.should have_forgotten_password
    end
    
    it "should redirect to home if the password was changed" do
      @user.forgot_password!
      c = dispatch_update(:user => {:password => "blah", :password_confirmation =>"blah"})
      @user.reload!
      User.authenticate(@user.email, "blah").should_not be_nil
      c.should redirect_to("/")
    end
  end
  
end