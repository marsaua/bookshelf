module Users
    class BooksController < ApplicationController
      before_action :authenticate_user!

      def index
        @user = User.find(params[:user_id])
        @books = @user.books
      end

      def show
        @user = User.find(params[:user_id])
        @book = @user.books.find(params[:id])
      end
    end
end
