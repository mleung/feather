module MerbAuth
  module Controller
    module Helpers
      protected
        # Returns true or false if the user is logged in.
        # Preloads @current_ma_user with the user model if they're logged in.
        def logged_in?
          !!current_ma_user
        end
    
        # Accesses the current user from the session.  Set it to :false if login fails
        # so that future calls do not hit the database.
        def current_ma_user
          @current_ma_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || false)
        end
    
        # Store the given user in the session.
        def current_ma_user=(new_user)
          session[MA[:single_resource]] = (!new_user || !new_user.kind_of?(MA[:user])) ? nil : new_user.id
          @current_ma_user = new_user
        end
    
        # Check if the user is authorized
        #
        # Override this method in your controllers if you want to restrict access
        # to only a few actions or if you want to check if the user
        # has the correct rights.
        #
        # Example:
        #
        #  # only allow nonbobs
        #  def authorized?
        #    current_ma_user.login != "bob"
        #  end
        def authorized?
          logged_in?
        end

        # Filter method to enforce a login requirement.
        #
        # To require logins for all actions, use this in your controllers:
        #
        #   before_filter :login_required
        #
        # To require logins for specific actions, use this in your controllers:
        #
        #   before_filter :login_required, :only => [ :edit, :update ]
        #
        # To skip this in a subclassed controller:
        #
        #   skip_before_filter :login_required
        #
        def login_required
          authorized? || throw(:halt, :access_denied)
        end

        # Redirect as appropriate when an access request fails.
        #
        # The default action is to redirect to the login screen.
        #
        # Override this method in your controllers if you want to have special
        # behavior in case the user is not authorized
        # to access the requested action.  For example, a popup window might
        # simply close itself.
        def access_denied
          case content_type
          when :html
            store_location
            redirect url(:login)
          when :xml
            basic_authentication.request
          end
        end
    
        # Store the URI of the current request in the session.
        #
        # We can return to this location by calling #redirect_back_or_default.
        def store_location
          session[:return_to] = request.uri
        end
    
        # Redirect to the URI stored by the most recent store_location call or
        # to the passed default.
        def redirect_back_or_default(default, notice = "")
          url = session[:return_to] || default
          session[:return_to] = nil
          redirect url, :notice => notice
        end

        # Called from #current_ma_user.  First attempt to login by the user id stored in the session.
        def login_from_session
          self.current_ma_user = MA[:user].find_with_conditions(:id => session[MA[:single_resource]]) if session[MA[:single_resource]]
        end

        # Called from #current_ma_user.  Now, attempt to login by basic authentication information.
        def login_from_basic_auth
          basic_authentication.authenticate do |email, password|
            self.current_ma_user = MA[:user].authenticate(email, password)
          end
        end

        # Called from #current_ma_user.  Finaly, attempt to login by an expiring token in the cookie.
        def login_from_cookie     
          user = cookies[:auth_token] && MA[:user].find_with_conditions(:remember_token => cookies[:auth_token])
          if user && user.remember_token?
            user.remember_me
            cookies[:auth_token] = { :value => user.remember_token, :expires => Time.parse(user.remember_token_expires_at.to_s) }
            self.current_ma_user = user
          end
        end
    end # Helpers
  end# Controllers
end # MerbAuth
