module MerbAuth
  class Users
    def index
      @users = User.all
      display @users
    end

    def show
      @user = User.get(params[:id])
      display @user
    end

    def edit
      @user = User.get(params[:id])
      display @user      
    end

    def update
      @user = User.get(params[:id])
      if @user.update_attributes(params[:user])
        redirect_back_or_default(url(:users))
      else
        render :edit
      end
    end
  end
end
