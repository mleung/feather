require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Articles, "index action" do
  before(:each) do
    dispatch_to(Articles, :index)
  end
end