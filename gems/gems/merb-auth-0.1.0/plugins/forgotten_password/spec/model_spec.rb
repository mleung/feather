require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Forgotten password for models" do
  
  before(:each) do
    User.clear_database_table
    @user = User.new(valid_user_hash.with(:password => "test", :password_confirmation => "test"))    
    @user.save
  end

  it "should not have a forgotten password" do
    @user.should_not have_forgotten_password
  end
  
  it "should have a forgotten password" do
    @user.forgot_password!
    @user.should have_forgotten_password
  end
  
  it "should have a forgotten password key 40 chars long when the password is forgotten" do
    @user.password_reset_key.should be_nil
    @user.forgot_password!
    @user.password_reset_key.should_not be_nil
  end
  
  it "should not allow duplicates of the key but should regenerate until it has a good one" do
    key1 = @user.class.make_key
    key2 = @user.class.make_key
    key1.should_not == key2
    @user.forgot_password!
    @user.send(:password_reset_key=, key1)
    @user.save
    @user.reload!
    @user.password_reset_key.should == key1
    
    user = User.create(valid_user_hash)
    
    User.should_receive(:make_key).exactly(3).times.and_return(key1,key1,key2)
    user.forgot_password!
  end
  
  it "should remove the forgotten password key if present when it is authenticated with the password" do
    # If the user remembers to log in then the password is no longer forgotten and this should be reset
    @user.forgot_password!
    @user.reload!
    @user.password_reset_key.should_not be_nil
    User.authenticate(@user.email, "test")
    @user.reload!
    @user.password_reset_key.should be_nil
  end
  
end