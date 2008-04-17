module Admin
  class Users < Base

    def index
      @users = User.all
      display @users
    end
    
    def show
      @user = User[params[:id]]
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
      @user = User[params[:id]]
      display @user
    end
    
    def update
      @user = User[params[:id]]
      if @user.update_attributes(params[:user])
        redirect_back_or_default(url(:admin_users))
      else
        render :edit
      end
    end
    
    def delete
      @user = User[params[:id]]
      @user.destroy!
      redirect url(:admin_users)
    end
    
  end
  
end