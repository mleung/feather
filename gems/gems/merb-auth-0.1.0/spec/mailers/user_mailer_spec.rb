require File.dirname(__FILE__) + '/../spec_helper'

describe MA::UserMailer do
  
  before(:all) do
    MA[:use_activation] = true
    
    DataMapper.setup(:default, 'sqlite3::memory:')
    Merb.stub!(:orm_generator_scope).and_return("datamapper")
    
    adapter_path = File.join( File.dirname(__FILE__), "..", "..", "lib", "merb-auth", "adapters")
    MA.register_adapter :datamapper, "#{adapter_path}/datamapper"
    MA.register_adapter :activerecord, "#{adapter_path}/activerecord"    
    MA.loaded

    class User
      include MA::Adapter::DataMapper
      include MerbAuth::Adapter::DataMapper::DefaultModelSetup
    end
  end
  
  def deliver(action, mail_opts= {},opts = {})
    MA::UserMailer.dispatch_and_deliver action, mail_opts, opts
    @delivery = Merb::Mailer.deliveries.last
  end
  
  before(:each) do
    @u = MA[:user].new(:email => "homer@simpsons.com", :login => "homer", :activation_code => "12345")
    @mailer_params = { :from      => "info@mysite.com",
                       :to        => @u.email,
                       :subject   => "Welcome to MySite.com" }
  end
  
  after(:each) do
    Merb::Mailer.deliveries.clear
  end
  
  it "should send mail to homer@simpsons.com for the signup email" do
    deliver(:signup, @mailer_params, :user => @u)
    @delivery.assigns(:headers).should include("to: homer@simpsons.com")
  end
  
  it "should send the mail from 'info@mysite.com' for the signup email" do
    deliver(:signup, @mailer_params, :user => @u)
    @delivery.assigns(:headers).should include("from: info@mysite.com")
  end
  
  it "should mention the users login in the text signup mail" do
    deliver(:signup, @mailer_params, :user => @u)
    @delivery.text.should include(@u.email)
  end
  
  it "should mention the activation link in the signup emails" do
    deliver(:signup, @mailer_params, :user => @u)
    the_url = MA::UserMailer.new.url(:user_activation, :activation_code => @u.activation_code)
    the_url.should_not be_nil
    @delivery.text.should include( the_url )   
  end
  
  it "should send mail to homer@simpson.com for the activation email" do
    deliver(:activation, @mailer_params, :user => @u)
    @delivery.assigns(:headers).should include("to: homer@simpsons.com")
  end
  
  it "should send the mail from 'info@mysite.com' for the activation email" do
    deliver(:activation, @mailer_params, :user => @u)
    @delivery.assigns(:headers).should include("from: info@mysite.com")    
  end
  
  it "should mention ther users login in the text activation mail" do
    deliver(:activation, @mailer_params, :user => @u)
    @delivery.text.should include(@u.email)
  end

end