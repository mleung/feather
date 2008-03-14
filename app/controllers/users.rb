require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
class Users < Application
  provides :xml
  
  skip_before :login_required
  
  def new
    only_provides :html
    @user = User.new(params[:user] || {})
    display @user
  end
  
  def create
    cookies.delete :auth_token
    
    @user = User.new(params[:user])
    if @user.save
      redirect_back_or_default('/')
    else
      render :new
    end
  end
  
end