require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

module Admin
  describe Plugins do
    before(:each) do
      @plugin = mock(:plugin)
      @plugins = [@plugin]
    end
    
    describe "/admin/plugins" do
      it "should get all plugins" do
        Plugin.should_receive(:all).and_return(@plugins)
        controller = dispatch_to(Plugins, :index) do |controller|
          controller.should_receive(:login_required).and_return(true)
          controller.should_receive(:load_plugins).and_return(true)
          controller.should_receive(:display).with(@plugins)
        end
        controller.assigns(:plugins).should == @plugins
        controller.should be_successful
      end
    end

    describe "/admin/plugins/1" do
      it "should display the plugin matching the id" do
        Plugin.should_receive("[]").with("1").and_return(@plugin)
        controller = dispatch_to(Plugins, :show, :id => "1") do |controller|
          controller.should_receive(:login_required).and_return(true)
          controller.should_receive(:load_plugins).and_return(true)
          controller.should_receive(:display).with(@plugin)
        end
        controller.assigns(:plugin).should == @plugin
        controller.should be_successful
      end
    end
  end
end
