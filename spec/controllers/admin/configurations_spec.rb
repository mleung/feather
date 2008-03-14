require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

describe Admin::Configurations, "index action" do
  before(:each) do
    dispatch_to(Admin::Configurations, :index)
  end
end