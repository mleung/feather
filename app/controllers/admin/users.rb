require File.join(File.dirname(__FILE__), "base")

module Feather
  module Admin
    class Users < Base
      before :find_user, :only => %w(edit update delete show)
      
      def index
        @users = Feather::User.all
        display @users
      end
      
      def show
        display @user
      end
      
      def new
        @user = Feather::User.new
        display @user
      end
      
      def create(user)
        @user = Feather::User.new(user)
        if @user.save
          redirect(url(:admin_users))
        else
          render :new
        end
      end
      
      def edit
        display @user
      end
      
      def update(user)
        if @user.update_attributes(user)
          redirect(url(:admin_user, @user))
        else
          display @user, :edit
        end
      end
      
      def destroy
        @user.destroy
        redirect(url(:admin_users))
      end
      
      private
        def find_user
          @user = Feather::User[params[:id]]
        end
    end
  end
end