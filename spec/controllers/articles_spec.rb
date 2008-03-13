require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Articles Controller", "index action" do
  before(:each) do
    @controller = Articles.build(fake_request)
    @controller.dispatch('index')
  end
end