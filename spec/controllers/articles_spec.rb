require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Articles do
  before(:each) do
    @article = mock(:article)
    @articles = [@article]
  end
  
  describe "/" do
    it "should return recent articles" do
      Article.should_receive(:find_recent).and_return @articles
      controller = dispatch_to(Articles, :index) do |controller|
        controller.expire_all_pages
        controller.should_receive(:display).with(@articles)
      end
      controller.assigns(:articles).should == @articles
      controller.should be_successful
    end
  end
end
