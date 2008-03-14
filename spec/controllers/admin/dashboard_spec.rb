require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

describe Admin::Dashboard, "index action" do
  before(:each) do
    dispatch_to(Admin::Dashboard, :index)
  end
  
  it "should have a route to /admin" do
    request_to("/admin") do |params|
      params[:controller].should == "admin/dashboard"
      params[:action].should == "index"
    end   
  end
  
  it "should successfully show the dashboard" do
    controller = get "/admin"
    controller.should be_successful
  end
  
end