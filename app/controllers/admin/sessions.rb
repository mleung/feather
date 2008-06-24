module Admin
  class Sessions < Base
    skip_before :login_required

    def new
      render
    end

    def create
      self.current_user = User.authenticate(params[:login], params[:password])
      if logged_in?
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        redirect_back_or_default('/')
      else
        render :new
      end
    end

    def destroy
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      redirect_back_or_default('/')
    end
  end
end
