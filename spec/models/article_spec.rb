require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Article do
  before(:all) do
    @article = mock(:article)
    @articles = [@article]
    end
    
    describe Article do
      it 'should create a new article' do
        b = Article.new
        b.user_id = 1
        b.title = "hai"
        b.content = "bai"
        b.should be_valid
      end
    end
  end
