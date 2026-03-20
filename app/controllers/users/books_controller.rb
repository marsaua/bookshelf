module Users
    class BooksController < ApplicationController
      before_action :authenticate_user!

      def index
        @user = User.find(params[:user_id])
        @books = @user.books
        @categories = @books.where.not(category: nil).distinct.pluck(:category)

        if params[:category].present?
          @my_books = @my_books.where(category: params[:category])
          @lent_books = @lent_books.where(category: params[:category])
        end
      end

      def show
        @user = User.find(params[:user_id])
        @book = @user.books.find(params[:id])
        @book_request = BookRequest.where(book: @book, requester_id: current_user.id).order(created_at: :desc).first
        @comments = Comment.where(book_id: @book.id)


      end
    end
end
