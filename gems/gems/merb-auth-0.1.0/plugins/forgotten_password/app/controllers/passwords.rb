module MerbAuth
  class Passwords < Application
  
    controller_for_slice :MerbAuth
      
    def _template_location(context, type = nil, controller = controller_name)
      if controller.nil? || controller != "merb_auth/passwords"
        "#{controller}/#{context}.#{type}"
      else
        "passwords/#{context}.#{type}"
      end
    end
    
    before :login_required, :only => [:edit, :update]
  
    # NEW shows the html form to initiate the forgotten password request
    def new
      render
    end
  
    # Edit shows the reset password form for a currently logged in person
    def edit
      @ivar = current_ma_user
      set_ivar
      render
    end
  
    # Initiates a password reset for forgoten password
    def create
      email = params[:email]
      @ivar = MA[:user].find_with_conditions(:email => email)
      raise NotFound if @ivar.nil?
      raise Unauthorized if logged_in? && @ivar != current_ma_user
      @ivar.forgot_password!
      set_ivar
      redirect_back_or_default("/", "We've sent you a link to reset your password.  Keep an eye on your inbox.")
    end
  
    # Reset is the link given in the email with the reset password code attached
    # This action at best should be a 1 hit wonder link to log in the user, reset the code and 
    # redirect to edit.  If There's an error send them to the new action
    def show
      id = params[:id]
      @ivar = MA[:user].find_with_conditions(:password_reset_key => id)
      if @ivar.nil?
        redirect_back_or_default "/"
      else
        self.current_ma_user = @ivar
        set_ivar
        redirect url(:merb_auth_edit_password_form)
      end
    end
  
  
    # Performs a password change for an existing user.  This is nice and big to ensure that we're only dealing with 
    # Changes to passwords.   Not arbitrary stuff.
    def update  
      @ivar = current_ma_user
      set_ivar
      if params[MA[:single_resource]][:password].nil?
        message[:notice] = "You must enter a password"
        return render(:edit)
      end
    
      if !@ivar.has_forgotten_password?
        if @ivar != MA[:user].authenticate(@ivar.email, params[:current_password])
          message[:notice] = "Your current password is incorrect"
          return render(:edit)
        end
      end

      @ivar.password = params[MA[:single_resource]][:password]
      @ivar.password_confirmation = params[MA[:single_resource]][:password_confirmation]
    
      if @ivar.save
        @ivar.clear_forgot_password!
        redirect_back_or_default("/", "Password Changed")
      else
        redirect url(:merb_auth_edit_password_form), "Password Not Changed"
      end     
    end
  
    private
    # sets the instance variable for the developer to use eg. @user
    def set_ivar
      instance_variable_set("@#{MA[:single_resource]}", @ivar)
    end
  
  end
end