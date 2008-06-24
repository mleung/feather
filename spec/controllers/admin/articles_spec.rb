require File.join(File.dirname(__FILE__), "../..", 'spec_helper.rb')

module Admin
  describe Articles do
    before(:each) do
      @article = mock(:article)
      @articles = [@article]
    end
    
    describe "/admin/articles" do
      it "should get all articles in descending created order" do
        Article.should_receive(:all).with(:order => [:created_at.desc], :offset => 0, :limit => 10).and_return(@articles)
        controller = dispatch_to(Articles, :index) do |controller|
          controller.should_receive(:login_required).and_return(true)
          controller.should_receive(:display).with(@articles)
        end
        controller.assigns(:articles).should == @articles
        controller.should be_successful
      end
    end

    describe "/admin/articles/1" do
      it "should display the article matching the id" do
        Article.should_receive("[]").with("1").and_return(@article)
        controller = dispatch_to(Articles, :show, :id => "1") do |controller|
          controller.should_receive(:login_required).and_return(true)
          controller.should_receive(:display).with(@article)
        end
        controller.assigns(:article).should == @article
        controller.should be_successful
      end
    end
  end
end
