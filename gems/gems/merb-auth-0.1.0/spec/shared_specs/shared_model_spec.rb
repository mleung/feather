describe "A MerbAuth User Model", :shared => true do
  
  before(:all) do
    raise "You need to set the MerbAuth[:user] class to use this spec" unless MA[:user].is_a?(Class)
  end
  
  before(:each) do
    MA[:user].clear_database_table
    @hash = valid_user_hash
    @user = MA[:user].new(@hash)
    MA[:from_email] = "example@email.com"
  end
  
  it "should include MerbAuth::Adapter::Common mixin" do
    MA[:user].should include(MA::Adapter::Common)  
  end
  
  it "should setup the name of the resource" do
    MA[:single_resource].should == :user    
  end
  
  it "should set the name of the collection" do
    MA[:plural_resource].should == :users    
  end
  
  describe "Fields" do
    
    before(:each) do
      MA[:use_activation] = true
    end
    
    it "should make a valid user" do
      user = MA[:user].new(valid_user_hash)
      user.save
      user.errors.should be_empty
    end
    
    it "should have a login field" do
      user = MA[:user].new
      user.should respond_to(:login)
      user.valid?
      user.errors.on(:login).should_not be_nil
    end
    
    it "should have an email field" do
      user = MA[:user].new
      user.should respond_to(:email)
      user.valid?
      user.errors.on(:email).should_not be_nil      
    end
    
    it "should add on some random numbers on the end if the username is already taken" do 
      hash = valid_user_hash.except(:login)
      hash[:email] = "homer@simpsons.com"
      u1 = MA[:user].new(hash)
      u1.save
      u1.should_not be_new_record
      u1.login.should == "homer"

      h2 = valid_user_hash.except(:login)
      h2[:email] = "homer@shelbyvile.com"
      u2 = MA[:user].new(h2)
      u2.save
      u2.should_not be_new_record
      u2.login.should match(/homer\d{3}/)
      u2.login.should == "homer000"

      h3 = valid_user_hash.except(:login)
      h3[:email] = "homer@hotmail.com"
      u3 = MA[:user].new(h3)
      u3.save
      u3.should_not be_new_record
      u3.login.should match(/homer\d{3}/)
      u3.login.should == "homer001"
    end
    
    it "should fail login if there are less than 3 chars" do
      user = MA[:user].new
      user.login = "AB"
      user.valid?
      user.errors.on(:login).should_not be_nil
    end
    
    it "should not fail login with between 3 and 40 chars" do
      user = MA[:user].new
      [3,40].each do |num|
        user.login = "a" * num
        user.valid?
        user.errors.on(:login).should be_nil
      end
    end
    
    it "should fail login with over 90 chars" do
      user = MA[:user].new
      user.login = "A" * 41
      user.valid?
      user.errors.on(:login).should_not be_nil    
    end
    
    it "should make sure login is unique regardless of case" do
      MA[:user].find_with_conditions(:login => "Daniel").should be_nil
      user = MA[:user].new( valid_user_hash.with(:login => "Daniel") )
      user2 = MA[:user].new( valid_user_hash.with(:login => "daniel"))
      user.save
      user.should_not be_a_new_record
      user2.save
      user2.should be_a_new_record
      user2.errors.on(:login).should_not be_nil
    end
    
    it "should downcase logins" do
      user = MA[:user].new( valid_user_hash.with(:login => "DaNieL"))
      user.login.should == "daniel"    
    end
    
    it "should authenticate a user using a class method" do
      hash = valid_user_hash
      user = MA[:user].new(hash)
      user.save
      user.should_not be_new_record
      user.activate
      MA[:user].authenticate(hash[:email], hash[:password]).should_not be_nil
    end
    
    it "should not authenticate a user using the wrong password" do
      user = MA[:user].new(valid_user_hash)  
      user.save

      user.activate
      MA[:user].authenticate(valid_user_hash[:email], "not_the_password").should be_nil
    end
    
    it "should not authenticate a user using the wrong login" do
      user = MA[:user].create(valid_user_hash)  

      user.activate
      MA[:user].authenticate("not_the_login@blah.com", valid_user_hash[:password]).should be_nil
    end
    
    it "should not authenticate a user that does not exist" do
      MA[:user].authenticate("i_dont_exist", "password").should be_nil
    end
    
  end
  
  describe "the password fields" do
    
    it "should respond to password" do
      @user.should respond_to(:password)    
    end

    it "should respond to password_confirmation" do
      @user.should respond_to(:password_confirmation)
    end

    it "should respond to crypted_password" do
      @user.should respond_to(:crypted_password)    
    end

    it "should require password if password is required" do
      user = MA[:user].new( valid_user_hash.without(:password))
      user.stub!(:password_required?).and_return(true)
      user.valid?
      user.errors.on(:password).should_not be_nil
      user.errors.on(:password).should_not be_empty
    end

    it "should set the salt" do
      user = MA[:user].new(valid_user_hash)
      user.salt.should be_nil
      user.send(:encrypt_password)
      user.salt.should_not be_nil    
    end

    it "should require the password on create" do
      user = MA[:user].new(valid_user_hash.without(:password))
      user.save
      user.errors.on(:password).should_not be_nil
      user.errors.on(:password).should_not be_empty
    end  

    it "should require password_confirmation if the password_required?" do
      user = MA[:user].new(valid_user_hash.without(:password_confirmation))
      user.save
      (user.errors.on(:password) || user.errors.on(:password_confirmation)).should_not be_nil
    end

    it "should fail when password is outside 4 and 40 chars" do
      [3,41].each do |num|
        user = MA[:user].new(valid_user_hash.with(:password => ("a" * num)))
        user.valid?
        user.errors.on(:password).should_not be_nil
      end
    end

    it "should pass when password is within 4 and 40 chars" do
      [4,30,40].each do |num|
        user = MA[:user].new(valid_user_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
        user.valid?
        user.errors.on(:password).should be_nil
      end    
    end

    it "should autenticate against a password" do
      user = MA[:user].new(valid_user_hash)
      user.save    
      user.should be_authenticated(valid_user_hash[:password])
    end

    it "should not require a password when saving an existing user" do
      hash = valid_user_hash
      user = MA[:user].new(hash)
      user.save
      user.should_not be_a_new_record
      user.login.should == hash[:login].downcase
      user = MA[:user].find_with_conditions(:login => hash[:login].downcase)
      user.password.should be_nil
      user.password_confirmation.should be_nil
      user.login = "some_different_login_to_allow_saving"
      (user.save).should be_true
    end
    
  end
  
  describe "activation setup" do
    
    before(:each) do
      MA[:use_activation] = true
    end
    
    it "should have an activation_code as an attribute" do
      @user.attributes.keys.any?{|a| a.to_s == "activation_code"}.should_not be_nil
    end

    it "should create an activation code on create" do
      @user.activation_code.should be_nil    
      @user.save
      @user.activation_code.should_not be_nil
    end

    it "should not be active when created" do
      @user.should_not be_activated
      @user.save
      @user.should_not be_activated    
    end

    it "should respond to activate" do
      @user.should respond_to(:activate)    
    end
    
    it "should respond to activated? & active?" do
      @user.save
      @user.should_not be_active
      @user.should_not be_activated
      @user.activate
      @user.reload
      @user.should be_active
      @user.should be_activated
    end

    it "should activate a user when activate is called" do
      @user.should_not be_activated
      @user.save
      @user.activate
      @user.should be_activated
      MA[:user].find_with_conditions(:email => @hash[:email]).should be_activated
    end

    it "should should show recently activated when the instance is activated" do
      @user.should_not be_recently_activated
      @user.activate
      @user.should be_recently_activated
    end

    it "should not show recently activated when the instance is fresh" do
      @user.activate
      @user = nil
      MA[:user].find_with_conditions(:email => @hash[:email]).should_not be_recently_activated
    end
    
    it "should send an email to ask for activation" do
      MA[:use_activation] = true
      MA::UserMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|   
        action.should == :signup
        mail_args.keys.should include(:from)
        mail_args.keys.should include(:to)
        mail_args.keys.should include(:subject)
        mail_args[:subject].should_not be_blank
        mail_args[:to].should == @user.email
        mailer_params[:user].should == @user
      end
      @user.save
    end
    
    it "should not send an email to ask for activation when use_activation is not set" do
      MA[:use_activation] = false
      MA::UserMailer.should_not_receive(:dispatch_and_deliver)
      @user.save
    end

    it "should send out a welcome email to confirm that the account is activated" do
      @user.save
      MA::UserMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
        action.should == :activation
        mail_args.keys.should include(:from)
        mail_args.keys.should include(:to)
        mail_args.keys.should include(:subject)
        mail_args[:to].should == @user.email
        mailer_params[:user].should == @user
      end
      @user.activate
    end
    
    it "should send a please activate email" do
      user = MA[:user].new(valid_user_hash)
      MA::UserMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
        action.should == :signup
        [:from, :to, :subject].each{ |f| mail_args.keys.should include(f)}
        mail_args[:to].should == user.email
        mailer_params[:user].should == user
      end
      user.save
      user.should_not  be_a_new_record
    end
  
    it "should not send a please activate email when updating" do
      user = MA[:user].new(valid_user_hash)
      user.save
      MA[:user].should_not_receive(:signup_notification)
      user.login = "not in the valid hash for login"
      user.save    
    end
    
    it "should check that a user is active if the configuration calls for activation" do
      MA[:use_activation] = true      
      hash = valid_user_hash
      hash2 = valid_user_hash
      user = MA[:user].new(hash)
      user.save
      user.reload
      MA[:user].authenticate(user.email, hash[:password]).should be_nil
      MA[:use_activation] = false
      u2 = MA[:user].new(hash2)
      u2.save
      u2.reload
      MA[:user].authenticate(u2.email, hash2[:password]).should == u2
      MA[:user].authenticate(user.email, hash[:passowrd]).should be_nil
      MA[:use_activateion] = true
      user.activate
      user.reload
      MA[:user].authenticate(user.email, hash[:password]).should == user
      MA[:user].authenticate(u2.email, hash2[:password]).should == u2
    end
    
    it "should not activate the user when use_activation is true" do
      MA[:use_activation] = true
      u = MA[:user].new(valid_user_hash)
      u.save
      u.should_not be_activated      
    end
    
    it "should set the use to active if there is no activation required" do
      MA[:use_activation] = false
      u = MA[:user].new(valid_user_hash)
      u.save
      u.should be_activated   
    end

  end

  describe "remember me" do
    predicate_matchers[:remember_token] = :remember_token?

    before do
      MA[:user].clear_database_table
      @user = MA[:user].new(valid_user_hash)
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
      time = DateTime.civil(2009,12,25)
      @user.remember_me_until(time)
      @user.remember_token_expires_at.should == time    
    end

    it "should set the remember_me token when remembering" do
      time = DateTime.civil(2009,12,25)
      @user.remember_me_until(time)
      @user.remember_token.should_not be_nil
      @user.save
      MA[:user].find_with_conditions(:login => @user.login).remember_token.should_not be_nil
    end

    it "should remember me for" do
      t = DateTime.now
      DateTime.stub!(:now).and_return(t)
      today = DateTime.now
      remember_until = today + (2* Merb::Const::WEEK) / Merb::Const::DAY
      @user.remember_me_for( Merb::Const::WEEK * 2)
      @user.remember_token_expires_at.should == (remember_until)
    end

    it "should remember_me for two weeks" do
      t = DateTime.now
      DateTime.stub!(:now).and_return(t)
      @user.remember_me
      @user.remember_token_expires_at.should == (DateTime.now + (2 * Merb::Const::WEEK ) / Merb::Const::DAY)
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

      @user = MA[:user].find_with_conditions(:email => @user.email)
      @user.remember_token.should_not be_nil

      @user.forget_me

      @user = MA[:user].find_with_conditions(:email => @user.email)
      @user.remember_token.should be_nil
      @user.remember_token_expires_at.should be_nil
    end
  end
  
end