require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "user_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe User do
  include UserSpecHelper
  
  before(:each) do
    User.clear_database_table
  end

  it "should have a login field" do
    user = User.new
    user.should respond_to(:login)
    user.valid?
    user.errors.on(:login).should_not be_nil
  end
  
  it "should fail login if there are less than 3 chars" do
    user = User.new
    user.login = "AB"
    user.valid?
    user.errors.on(:login).should_not be_nil
  end
  
  it "should not fail login with between 3 and 40 chars" do
    user = User.new
    [3,40].each do |num|
      user.login = "a" * num
      user.valid?
      user.errors.on(:login).should be_nil
    end
  end
  
  it "should fail login with over 90 chars" do
    user = User.new
    user.login = "A" * 41
    user.valid?
    user.errors.on(:login).should_not be_nil    
  end
  
  it "should make a valid user" do
    user = User.new(valid_user_hash)
    user.save
    user.errors.should be_empty
    
  end
  
  it "should make sure login is unique" do
    user = User.new( valid_user_hash.with(:login => "Daniel") )
    user2 = User.new( valid_user_hash.with(:login => "Daniel"))
    user.save.should be_true
    user.login = "Daniel"
    user2.save.should be_false
    user2.errors.on(:login).should_not be_nil
  end
  
  it "should make sure login is unique regardless of case" do
    User.find_with_conditions(:login => "Daniel").should be_nil
    user = User.new( valid_user_hash.with(:login => "Daniel") )
    user2 = User.new( valid_user_hash.with(:login => "daniel"))
    user.save.should be_true
    user.login = "Daniel"
    user2.save.should be_false
    user2.errors.on(:login).should_not be_nil
  end
  
  it "should downcase logins" do
    user = User.new( valid_user_hash.with(:login => "DaNieL"))
    user.login.should == "daniel"    
  end  
  
  it "should authenticate a user using a class method" do
    user = User.new(valid_user_hash)
    user.save
    User.authenticate(valid_user_hash[:login], valid_user_hash[:password]).should_not be_nil
  end
  
  it "should not authenticate a user using the wrong password" do
    user = User.new(valid_user_hash)  
    user.save
    User.authenticate(valid_user_hash[:login], "not_the_password").should be_nil
  end
  
  it "should not authenticate a user using the wrong login" do
    user = User.create(valid_user_hash)  
    User.authenticate("not_the_login", valid_user_hash[:password]).should be_nil
  end
  
  it "should not authenticate a user that does not exist" do
    User.authenticate("i_dont_exist", "password").should be_nil
  end
  
  
end

describe User, "the password fields for User" do
  include UserSpecHelper
  
  before(:each) do
    User.clear_database_table
    @user = User.new( valid_user_hash )
  end
  
  it "should respond to password" do
    @user.should respond_to(:password)    
  end
  
  it "should respond to password_confirmation" do
    @user.should respond_to(:password_confirmation)
  end
  
  it "should have a protected password_required method" do
    @user.protected_methods.should include("password_required?")
  end
  
  it "should respond to crypted_password" do
    @user.should respond_to(:crypted_password)    
  end
  
  it "should require password if password is required" do
    user = User.new( valid_user_hash.without(:password))
    user.stub!(:password_required?).and_return(true)
    user.valid?
    user.errors.on(:password).should_not be_nil
    user.errors.on(:password).should_not be_empty
  end
  
  it "should set the salt" do
    user = User.new(valid_user_hash)
    user.salt.should be_nil
    user.send(:encrypt_password)
    user.salt.should_not be_nil    
  end
  
  it "should require the password on create" do
    user = User.new(valid_user_hash.without(:password))
    user.save
    user.errors.on(:password).should_not be_nil
    user.errors.on(:password).should_not be_empty
  end  
  
  it "should require password_confirmation if the password_required?" do
    user = User.new(valid_user_hash.without(:password_confirmation))
    user.save
    (user.errors.on(:password) || user.errors.on(:password_confirmation)).should_not be_nil
  end
  
  it "should fail when password is outside 4 and 40 chars" do
    [3,41].each do |num|
      user = User.new(valid_user_hash.with(:password => ("a" * num)))
      user.valid?
      user.errors.on(:password).should_not be_nil
    end
  end
  
  it "should pass when password is within 4 and 40 chars" do
    [4,30,40].each do |num|
      user = User.new(valid_user_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
      user.valid?
      user.errors.on(:password).should be_nil
    end    
  end
  
  it "should autenticate against a password" do
    user = User.new(valid_user_hash)
    user.save    
    user.should be_authenticated(valid_user_hash[:password])
  end
  
  it "should not require a password when saving an existing user" do
    user = User.create(valid_user_hash)
    user = User.find_with_conditions(:login => valid_user_hash[:login])
    user.password.should be_nil
    user.password_confirmation.should be_nil
    user.login = "some_different_login_to_allow_saving"
    (user.save).should be_true
  end
  
end


describe User, "remember_me" do
  include UserSpecHelper
  
  predicate_matchers[:remember_token] = :remember_token?
  
  before do
    User.clear_database_table
    @user = User.new(valid_user_hash)
  end
  
  it "should have a remember_token_expires_at attribute" do
    @user.attributes.keys.any?{|a| a.to_s == "remember_token_expires_at"}.should_not be_nil
  end  
  
  it "should respond to remember_token?" do
    @user.should respond_to(:remember_token?)
  end
  
  it "should return true if remember_token_expires_at is set and is in the future" do
    @user.remember_token_expires_at = DateTime.now + 3600
    @user.should remember_token    
  end
  
  it "should set remember_token_expires_at to a specific date" do
    time = Time.mktime(2009,12,25)
    @user.remember_me_until(time)
    @user.remember_token_expires_at.should == time    
  end
  
  it "should set the remember_me token when remembering" do
    time = Time.mktime(2009,12,25)
    @user.remember_me_until(time)
    @user.remember_token.should_not be_nil
    @user.save
    User.find_with_conditions(:login => valid_user_hash[:login]).remember_token.should_not be_nil
  end
  
  it "should remember me for" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    today = Time.now
    remember_until = today + (2* Merb::Const::WEEK)
    @user.remember_me_for( Merb::Const::WEEK * 2)
    @user.remember_token_expires_at.should == (remember_until)
  end
  
  it "should remember_me for two weeks" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    @user.remember_me
    @user.remember_token_expires_at.should == (Time.now + (2 * Merb::Const::WEEK ))
  end
  
  it "should forget me" do
    @user.remember_me
    @user.save
    @user.forget_me
    @user.remember_token.should be_nil
    @user.remember_token_expires_at.should be_nil    
  end
  
  it "should persist the forget me to the database" do
    @user.remember_me
    @user.save
    
    @user = User.find_with_conditions(:login => valid_user_hash[:login])
    @user.remember_token.should_not be_nil
    
    @user.forget_me

    @user = User.find_with_conditions(:login => valid_user_hash[:login])
    @user.remember_token.should be_nil
    @user.remember_token_expires_at.should be_nil
  end
  
end