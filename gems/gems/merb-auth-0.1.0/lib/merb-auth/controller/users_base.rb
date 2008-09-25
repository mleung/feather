module MerbAuth
  module Controller
    
    # Provides basic functionality for the users controller.  Allows creation of a new user and activation
    module UsersBase
      
      def self.included(base)
        # base.send(:skip_before, :login_required)
        base.send(:include, InstanceMethods)
        base.send(:show_action, :new, :create, :activate)
      end
      
      module InstanceMethods
        # Displays the new form for the user
        def new
          only_provides :html
          @ivar = MA[:user].new(params[MA[:single_resource]] || {})
          set_ivar
          display @ivar
        end

        def create
          cookies.delete :auth_token

          @ivar = MA[:user].new(params[MA[:single_resource]])
          set_ivar
          if @ivar.save
            self.current_ma_user = @ivar unless MA[:use_activation]
            redirect_back_or_default('/')

          else
            render :new
          end
        end

        def activate
          self.current_ma_user = MA[:user].find_with_conditions(:activation_code => params[:activation_code])
          if logged_in? && !current_ma_user.activated?
            Merb.logger.info "Activated #{current_ma_user}"
            current_ma_user.activate
          end
          redirect_back_or_default('/')
        end

        private
        # sets the instance variable for the developer to use eg. @user
        def set_ivar
          instance_variable_set("@#{MA[:single_resource]}", @ivar)
        end
        
      end # InstanceMethods
      
    end # UsersBase
  end # Controllers
end #MerbAuth
