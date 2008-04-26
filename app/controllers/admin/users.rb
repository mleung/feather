module Admin
  class Users < Base
    before :find_user, :only => %w(edit update delete show)

    def index
      @users = User.all
      display @users
    end

    def show
      display @user
    end

    def new
      @user = User.new(params[:user] || {})
      display @user
    end

    def create
      cookies.delete :auth_token
      @user = User.new(params[:user])
      if @user.save
        redirect_back_or_default(url(:admin_users))
      else
        render :new
      end
    end

    def edit
      display @user
    end

    def update
      if @user.update_attributes(params[:user])
        redirect_back_or_default(url(:admin_users))
      else
        render :edit
      end
    end

    def delete
      @user.destroy!
      redirect url(:admin_users)
    end

    private
      def find_user
        @user = User[params[:id]]
      end    
  end
end