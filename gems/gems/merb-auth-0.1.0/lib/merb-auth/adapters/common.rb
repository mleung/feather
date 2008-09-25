module MerbAuth
  module Adapter
    module Common
      
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend,  ClassMethods)
      end
      
      
      module InstanceMethods
        
        # Encrypts the password with the user salt
        def encrypt(password)
          self.class.encrypt(password, salt)
        end
        
        def encrypt_password
          return if password.blank?
          self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{MA[:login_field]}--") if new_record?
          self.crypted_password = encrypt(password)
        end
        
        def authenticated?(password)
          crypted_password == encrypt(password)
        end
        
        def password_required?
          crypted_password.blank? || !password.blank?
        end
        
        def activate
          self.reload unless new_record? # Make sure the model is up to speed before we try to save it
          set_activated_data!
          self.save

          # send mail for activation
          send_activation_notification  if MA[:use_activation]
        end
        
        # Returns true if the user has just been activated.
        def recently_activated?
          @activated
        end

        def activated?
         return false if self.new_record?
         !! activation_code.nil?
        end
        
        # Alias for <tt>activated?</tt>
        def active?; activated?; end
        
        def set_login
          return nil unless self.login.nil?
          return nil if self.email.nil?
          logn = self.email.split("@").first
          # Check that that login is not taken
          taken_logins = self.class.find_all_with_login_like("#{logn}%").map{|u| u.login}
          if taken_logins.empty?
            self.login = logn
          else
            taken_logins.first =~ /(\d*)$/
            if $1.blank?
              self.login = "#{logn}000"
            else
              self.login ="#{logn}#{$1.succ}"
            end
          end
        end
        
        def make_activation_code
          if MA[:use_activation]
            self.activation_code = self.class.make_key
          else
            set_activated_data!
          end
        end
        
        def remember_token?
          remember_token_expires_at && DateTime.now < DateTime.parse(remember_token_expires_at.to_s)
        end

        def remember_me_until(time)
          self.remember_token_expires_at = time
          self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
          save
        end

        # Useses seconds for the time
        def remember_me_for(time)
          time = time / Merb::Const::DAY
          remember_me_until (DateTime.now + time)
        end

        # These create and unset the fields required for remembering users between browser closes
        # Default of 2 weeks 
        def remember_me
          remember_me_for (Merb::Const::WEEK * 2)
        end

        def forget_me
          self.remember_token_expires_at = nil
          self.remember_token            = nil
          self.save
        end
        
        def send_activation_notification
          if MA[:use_activation]
            deliver_email(:activation, :subject => (MA[:activation_subject] || "Welcome" ))
          end
        end

        def send_signup_notification
          if MA[:use_activation]
            deliver_email(:signup, :subject => (MA[:welcome_subject] || "Please Activate Your Account") )
          end
        end

        def send_forgot_password
          deliver_email(:forgot_password, :subject => (MA[:password_request_subject] || "Request to change your password"))
        end

        def deliver_email(action, params)
          from = MA[:from_email]
          MA::UserMailer.dispatch_and_deliver(action, params.merge(:from => from, :to => self.email), MA[:single_resource] => self)
        end
        
        private
        def set_activated_data!
          @activated = true
          self.activated_at = DateTime.now
          self.activation_code = nil
          true
        end       
        
      end
      
      module ClassMethods
        
        # Encrypts some data with the salt.
        def encrypt(password, salt)
          Digest::SHA1.hexdigest("--#{salt}--#{password}--")
        end
        
        # Authenticates a user by their login field and unencrypted password.  Returns the user or nil.
        def authenticate(field, password)
          @u = find_active_with_conditions(MA[:login_field] => field)
          @u = @u && @u.authenticated?(password) ? @u : nil
        end
        
        def make_key
          Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
        end
        
      end
      
    end
  end
end