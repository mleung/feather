require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Feather::Article do
  before(:all) do
    @article = mock(:article)
    @articles = [@article]
    end

    describe Feather::Article do
      it 'should create a new article' do
        b = Feather::Article.new
        b.user_id = 1
        b.title = "hai"
        b.content = "bai"
        b.should be_valid
      end
    end
  end
