class BooksController < ApplicationController
    before_action :authenticate_user!
    before_action :set_book, only: [:show, :edit, :update, :destroy, :toggle_lent]

    def index
        @my_books = current_user.books.where(lent_to_friend: [false, nil])
        @lent_books = current_user.books.where(lent_to_friend: true)
    end

    def show
    end

    def new
        @book = Book.new
    end

    def create
        @book = current_user.books.build(book_params)
        if @book.save
            redirect_to books_path, notice: "Book added!"
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @book.update(book_params)
            redirect_to books_path
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def toggle_lent
        @book.update(lent_to_friend: !@book.lent_to_friend)
        redirect_to books_path
    end

    def search
        return render json: [] if params[:query].blank?
        @results = GoogleBooksService.search(params[:query])
        render json: @results
    end

    def destroy
        @book.destroy
        redirect_to books_path
    end

    private

    def set_book
        @book = current_user.books.find(params[:id])
    end

    def book_params
        params.require(:book).permit(:title, :author, :description, :cover_url, :image)
    end
end
