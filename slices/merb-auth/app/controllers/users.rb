module MerbAuth
  class Users
    def index
      store_location
      @users = User.all
      display @users
    end

    def show(id)
      @user = User.get(id)
      display @user
    end

    def edit(id)
      @user = User.get(id)
      display @user      
    end

    def delete(id)
      User.get(id).destroy
      redirect url(:users)
    end

    def update(id, user)
      @user = User.get(id)
      if @user.update_attributes(user)
        redirect_back_or_default(url(:users))
      else
        render :edit
      end
    end
  end
end
