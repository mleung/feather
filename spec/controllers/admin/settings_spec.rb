require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

describe Admin::Settings, "index action" do
  before(:each) do
    dispatch_to(Admin::Settings, :index)
  end
end