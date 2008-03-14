require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

describe Admin::Configurations, "show action" do
  before(:each) do
    dispatch_to(Admin::Configurations, :show)
  end
  
  it "should be be succesful" do
    controller = get "/show"
    controller.should be_successful
  end
  
end