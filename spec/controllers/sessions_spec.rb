require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "user_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")
require 'cgi'

describe "Sessions Controller", "index action" do
  include UserSpecHelper
  
  before(:each) do
    User.clear_database_table
    @quentin = User.create(valid_user_hash.with(:login => "quentin", :password => "test", :password_confirmation => "test"))
    @controller = Sessions.new(fake_request)
  end
  
  it "should have a route to Sessions#new from '/login'" do
    request_to("/login") do |params|
      params[:controller].should == "Sessions"
      params[:action].should == "create"
    end   
  end
  
  it "should route to Sessions#create from '/login' via post" do
    request_to("/login", :post) do |params|
      params[:controller].should  == "Sessions"
      params[:action].should      == "create"
    end      
  end
  
  it "should have a named route :login" do
    @controller.url(:login).should == "/login"
  end
  
  it "should have route to Sessions#destroy from '/logout' via delete" do
    request_to("/logout", :delete) do |params|
      params[:controller].should == "Sessions"
      params[:action].should    == "destroy"
    end   
  end
  
  it "should route to Sessions#destroy from '/logout' via get" do
    request_to("/logout") do |params|
      params[:controller].should == "Sessions" 
      params[:action].should     == "destroy"
    end
  end

  it 'logins and redirects' do
    controller = post "/login", :login => 'quentin', :password => 'test'
    controller.session[:user].should_not be_nil
    controller.session[:user].should == @quentin.id
    controller.should redirect_to("/")
  end
   
  it 'fails login and does not redirect' do
    controller = post "/login", :login => 'quentin', :password => 'bad password'
    controller.session[:user].should be_nil
    controller.should be_successful
  end

  it 'logs out' do
    controller = get("/logout"){|controller| controller.stub!(:current_user).and_return(@quentin) }
    controller.session[:user].should be_nil
    controller.should redirect
  end

  it 'remembers me' do
    controller = post "/login", :login => 'quentin', :password => 'test', :remember_me => "1"
    controller.cookies["auth_token"].should_not be_nil
  end
 
  it 'does not remember me' do
    controller = post "/login", :login => 'quentin', :password => 'test', :remember_me => "0"
    controller.cookies["auth_token"].should be_nil
  end
  
  it 'deletes token on logout' do
    controller = get("/logout") {|request| request.stub!(:current_user).and_return(@quentin) }
    controller.cookies["auth_token"].should == nil
  end
  
  
  it 'logs in with cookie' do
    @quentin.remember_me
    controller = get "/login" do |c|
      c.request.env[Merb::Const::HTTP_COOKIE] = "auth_token=#{@quentin.remember_token}"
    end
    controller.should be_logged_in
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token user.remember_token
  end
end