require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

module Admin
  describe Configurations do
    before(:each) do
      @configuration = mock(:configuration)
    end

    describe "/admin/configurations" do
      it "should get current configuration" do
        Configuration.stub!(:current).and_return(@configuration)
        controller = dispatch_to(Configurations, :show) do |controller|
          controller.should_receive(:login_required).and_return(true)
          controller.should_receive(:display).with(@configuration)
        end
        controller.assigns(:configuration).should == @configuration
        controller.should be_successful
      end
    end
  end
end
