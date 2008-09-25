module MerbAuth
  module Controller
    module Tester
      def self.included(base)
        base.send(:include, InstanceMethods)
      end
      
      module InstanceMethods
        def new
          "NEW TEST"
        end
      end
    end          
  end
  
  Users.send(:include, Controller::Tester) # include the plugin into the Users controller to override the behaviour
end